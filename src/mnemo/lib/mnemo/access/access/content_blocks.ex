defmodule Mnemo.Access.ContentBlocks do
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.{SubjectSection, ContentBlock}
  require Ecto.Query
  import Ecto.Query, only: [from: 2]
  alias Ecto.Multi

  def create(section_id, type \\ "static") do
    current_count =
      PGRepo.one(
        from(b in ContentBlock,
          where: b.subject_section_id == ^section_id,
          select: count(b.id)
        )
      )

    PGRepo.get(SubjectSection, section_id)
    |> Ecto.build_assoc(:content_blocks)
    |> Map.put(:type, type)
    |> Map.put(:order_in_section, current_count)
    |> PGRepo.insert()
  end

  def delete(content_block_id) do
    PGRepo.get(ContentBlock, content_block_id)
    |> PGRepo.delete()
  end

  def save(content_block) do
    Ecto.Changeset.cast(%ContentBlock{id: content_block["id"]}, content_block, [
      :subject_section_id,
      :testable,
      :order_in_section,
      :media,
      :static_content,
      :saq_question_img,
      :saq_question_text,
      :saq_answer_choices,
      :mcq_question_img,
      :mcq_question_text,
      :mcq_answer_choices,
      :mcq_answer_correct,
      :fibq_question_img,
      :fibq_question_text_template,
      :fc_front_content,
      :fc_back_content
    ])
    |> PGRepo.update()
  end

  def all(section_id) do
    case PGRepo.get(SubjectSection, section_id) do
      nil ->
        []

      section ->
        PGRepo.preload(section, :content_blocks)
        |> Map.get(:content_blocks, [])
    end
  end

  def one(content_block_id) do
    PGRepo.get(ContentBlock, content_block_id)
  end

  @doc """
  Returns the "latest", i.e. the content_block with the highest order.
  """
  def latest(section_id) do
    from(cb in ContentBlock,
      where: cb.section_id == ^section_id,
      order_by: cb.order_in_section,
      limit: 1
    )
    |> Repo.one()
  end

  # Ignore transferring section in the off chance the section is the same.
  def reorder(content_block_id, new_idx, new_section_id)
      when new_section_id == content_block_id.subject_section_id do
    reorder(content_block_id, new_idx)
  end

  # Will both reorder AND redefine the block's parent section.
  # Removes block from previous section, reordering all blocks,
  # Inserts block in new section at given idx, reordering blocks in new section,
  # Updates block's parent section to match new section.
  def reorder(content_block_id, new_idx, new_section_id) do
    content_block_in_question = PGRepo.get(ContentBlock, content_block_id)
    original_content_block_idx = content_block_in_question.order_in_section

    blocks_to_reorder_old_section =
      PGRepo.all(
        from(c in ContentBlock,
          where: c.order_in_section > ^content_block_in_question.order_in_section,
          where: c.subject_section_id == ^content_block_in_question.subject_section_id,
          order_by: c.order_in_section
        )
      )

    blocks_to_reorder_new_section =
      PGRepo.all(
        from(c in ContentBlock,
          where: c.order_in_section >= ^content_block_in_question.order_in_section,
          where: c.subject_section_id == ^new_section_id,
          order_by: c.order_in_section
        )
      )

    reorder_multi(blocks_to_reorder_new_section, content_block_in_question, new_idx + 1, new_idx)
    |> remove_multi(blocks_to_reorder_old_section, original_content_block_idx)
    |> Multi.update(
      {:new_section_content_block, content_block_in_question.id},
      Ecto.Changeset.cast(content_block_in_question, %{subject_section_id: new_section_id}, [
        :subject_section_id
      ])
    )
    |> PGRepo.transaction()
  end

  def reorder(content_block_id, new_idx) do
    content_block_in_question = PGRepo.get(ContentBlock, content_block_id)

    cond do
      content_block_in_question.order_in_section == new_idx ->
        {:ok, content_block_in_question}

      content_block_in_question.order_in_section < new_idx ->
        reorder_upwards(content_block_in_question, new_idx)

      content_block_in_question.order_in_section > new_idx ->
        reorder_downwards(content_block_in_question, new_idx)
    end
  end

  defp reorder_upwards(content_block_in_question, new_idx) do
    blocks_to_reorder =
      PGRepo.all(
        from(c in ContentBlock,
          where: c.order_in_section > ^content_block_in_question.order_in_section,
          where: c.order_in_section <= ^new_idx,
          where: c.subject_section_id == ^content_block_in_question.subject_section_id,
          order_by: c.order_in_section
        )
      )

    reorder_multi(
      blocks_to_reorder,
      content_block_in_question,
      content_block_in_question.order_in_section,
      new_idx
    )
    |> PGRepo.transaction()
  end

  defp reorder_downwards(content_block_in_question, new_idx) do
    blocks_to_reorder =
      PGRepo.all(
        from(c in ContentBlock,
          where: c.order_in_section < ^content_block_in_question.order_in_section,
          where: c.order_in_section >= ^new_idx,
          where: c.subject_section_id == ^content_block_in_question.subject_section_id,
          order_by: c.order_in_section
        )
      )

    reorder_multi(blocks_to_reorder, content_block_in_question, new_idx + 1, new_idx)
    |> PGRepo.transaction()
  end

  defp remove_multi(multi = %Ecto.Multi{}, blocks_to_reorder, content_block_in_question_idx) do
    Enum.reduce(blocks_to_reorder, {content_block_in_question_idx, multi}, fn reorder_block,
                                                                              {idx, multi} ->
      {idx + 1,
       Multi.update(
         multi,
         {:remove_content_block, reorder_block.id},
         Ecto.Changeset.cast(reorder_block, %{order_in_section: idx}, [:order_in_section])
       )}
    end)
    |> elem(1)
  end

  defp reorder_multi(
         multi = %Ecto.Multi{} \\ Multi.new(),
         blocks_to_reorder,
         content_block_in_question,
         reduce_start_idx,
         target_idx
       ) do
    # We pass in {new_idx + 1, _} as the first value so we have a way of keeping track of the
    # idx, which we use to increment the order_in_section of each section.
    Enum.reduce(blocks_to_reorder, {reduce_start_idx, multi}, fn reorder_block, {idx, multi} ->
      {idx + 1,
       Multi.update(
         multi,
         # the Multi name
         {:content_block, reorder_block.id},
         Ecto.Changeset.cast(reorder_block, %{order_in_section: idx}, [:order_in_section])
       )}
    end)
    |> elem(1)
    # Now we update the content_block_in_question
    |> Multi.update(
      {:reordered_content_block, content_block_in_question.id},
      Ecto.Changeset.cast(content_block_in_question, %{order_in_section: target_idx}, [
        :order_in_section
      ])
    )
  end
end
