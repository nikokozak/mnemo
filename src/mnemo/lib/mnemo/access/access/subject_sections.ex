defmodule Mnemo.Access.SubjectSections do
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.{Subject, SubjectSection}
  require Ecto.Query
  alias Ecto.Multi
  import Ecto.Query, only: [from: 2]

  def one(section_id) do
    PGRepo.get(SubjectSection, section_id)
  end

  def create(subject_id) do
    current_count =
      PGRepo.one(
        from(s in SubjectSection,
          where: s.subject_id == ^subject_id,
          select: count(s.id)
        )
      )

    PGRepo.get(Subject, subject_id)
    |> Ecto.build_assoc(:sections)
    |> Map.put(:order_in_subject, current_count)
    |> PGRepo.insert()
  end

  def save(section) do
    Ecto.Changeset.cast(%SubjectSection{id: section["id"]}, section, [
      :title
    ])
    |> PGRepo.update()
  end

  def delete(section_id) do
    PGRepo.get(SubjectSection, section_id)
    |> PGRepo.delete()
  end

  def reorder(section_id, new_idx) do
    section_in_question = PGRepo.get(SubjectSection, section_id)

    cond do
      section_in_question.order_in_subject == new_idx ->
        {:ok, section_in_question}

      section_in_question.order_in_subject < new_idx ->
        reorder_upwards(section_in_question, new_idx)

      section_in_question.order_in_subject > new_idx ->
        reorder_downwards(section_in_question, new_idx)
    end
  end

  defp reorder_upwards(section_in_question, new_idx) do
    sections_to_reorder =
      PGRepo.all(
        from(s in SubjectSection,
          where: s.order_in_subject > ^section_in_question.order_in_subject,
          where: s.order_in_subject <= ^new_idx,
          where: s.subject_id == ^section_in_question.subject_id,
          order_by: s.order_in_subject
        )
      )

    reorder_multi(
      sections_to_reorder,
      section_in_question,
      section_in_question.order_in_subject,
      new_idx
    )
    |> PGRepo.transaction()
  end

  defp reorder_downwards(section_in_question, new_idx) do
    sections_to_reorder =
      PGRepo.all(
        from(s in SubjectSection,
          where: s.order_in_subject < ^section_in_question.order_in_subject,
          where: s.order_in_subject >= ^new_idx,
          where: s.subject_id == ^section_in_question.subject_id,
          order_by: s.order_in_subject
        )
      )

    reorder_multi(sections_to_reorder, section_in_question, new_idx + 1, new_idx)
    |> PGRepo.transaction()
  end

  defp reorder_multi(sections_to_reorder, section_in_question, reduce_start_idx, target_idx) do
    # We pass in {new_idx + 1, _} as the first value so we have a way of keeping track of the
    # idx, which we use to increment the order_in_subject of each section.
    Enum.reduce(sections_to_reorder, {reduce_start_idx, Multi.new()}, fn reorder_section,
                                                                         {idx, multi} ->
      {idx + 1,
       Multi.update(
         multi,
         # the Multi name
         {:section, reorder_section.id},
         Ecto.Changeset.cast(reorder_section, %{order_in_subject: idx}, [:order_in_subject])
       )}
    end)
    |> elem(1)
    # Now we update the section_in_question
    |> Multi.update(
      {:reordered_section, section_in_question.id},
      Ecto.Changeset.cast(section_in_question, %{order_in_subject: target_idx}, [
        :order_in_subject
      ])
    )
  end
end
