defmodule Mnemo.Access.ContentBlocks do
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.{SubjectSection, ContentBlock}

  def create(section_id, type \\ "static") do
    PGRepo.get(SubjectSection, section_id)
    |> Ecto.build_assoc(:content_blocks)
    |> Map.put(:type, type)
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
      :saq_answer_correct,
      :mcq_question_img,
      :mcq_question_text,
      :mcq_answer_choices,
      :mcq_answer_correct,
      :fibq_question_img,
      :fibq_template_text,
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
end
