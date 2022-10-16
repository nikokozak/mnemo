defmodule Mnemo.Managers.Content do
  alias Mnemo.Access

  def enroll(student_id, subject_id) do
    case Access.StudentProgressions.create(student_id, subject_id) do
      {:error, %{errors: [owner_id: {_, [constraint: :unique, constraint_name: _]}]}} ->
        {:error, :already_enrolled}

      success ->
        success
    end
  end

  def student_progressions(student_id) do
    Access.StudentProgressions.all(student_id)
  end

  def student_progression(progression_id) do
    Access.StudentProgressions.one(progression_id)
  end

  def student_progression(student_id, subject_id) do
    Access.StudentProgressions.get(student_id, subject_id)
  end

  def save_progress(student_id, subject_id, new_block_id) do
    Access.StudentProgressions.save(student_id, subject_id, new_block_id)
  end

  def delete_student_progression(progression_id) do
    Access.StudentProgressions.delete(progression_id)
  end

  def create_student_subject(student_id) do
    Access.Subjects.create(student_id)
  end

  def delete_student_subject(subject_id) do
    Access.Subjects.delete(subject_id)
  end

  def save_student_subject(subject) do
    Access.Subjects.save(subject)
  end

  def student_subjects(student_id) do
    Access.Subjects.all(student_id)
  end

  def student_subject(subject_id) do
    Access.Subjects.one(subject_id)
  end

  def subject_section(section_id) do
    Access.SubjectSections.one(section_id)
  end

  def subject_sections(subject_id) do
    Access.SubjectSections.all(subject_id)
  end

  def create_section(subject_id) do
    Access.SubjectSections.create(subject_id)
  end

  def save_section(section) do
    Access.SubjectSections.save(section)
  end

  # TODO: ponder whether section_cursor is necessary, or we can derive it all
  # from the content block. Might only be necessary here: in order to sift
  # through progressions we would need to access the section_id of every
  # content_block, making it much more expensive than simply looking up the one value.
  # That said, maybe it *should* be expensive for simplicity's sake.
  #
  # Needs to look for progressions where this section_id was in the cursor
  # And replace both the section and the content_block.
  def delete_section(section_id) do
    {:ok, deleted_section} = Access.SubjectSections.delete(section_id)
    subject_id = deleted_section.subject_id

    case Access.SubjectSections.latest(subject_id) do
      nil ->
        {:ok, deleted_section}

      next_section ->
        next_block = Access.ContentBlocks.latest(next_section.id)
        {_num_replaced, _} = Access.StudentProgressions.replace_content_block_cursors(next_block)
        {:ok, deleted_section}
    end
  end

  def reorder_subject_section(section_id, new_idx) do
    Access.SubjectSections.reorder(section_id, new_idx)
  end

  def content_block(content_block_id) do
    Access.ContentBlocks.one(content_block_id)
  end

  def content_blocks(section_id) do
    Access.ContentBlocks.all(section_id)
  end

  def create_content_block(section_id, type) do
    Access.ContentBlocks.create(section_id, type)
  end

  def save_content_block(content_block) do
    Access.ContentBlocks.save(content_block)
  end

  # Needs to look for progressions where this content_block_id was in the cursor
  # And replace the content_block and the section if necessary.
  def delete_content_block(content_block_id) do
    Access.ContentBlocks.delete(content_block_id)
  end

  def reorder_content_block(content_block_id, new_idx, new_section_idx) do
    Access.ContentBlocks.reorder(content_block_id, new_idx, new_section_idx)
  end

  def reorder_content_block(content_block_id, new_idx) do
    Access.ContentBlocks.reorder(content_block_id, new_idx)
  end

  def consume_content_block(progression_id) do
    Access.StudentProgressions.mark_block_completed(progression_id)
  end

  def move_cursor_to(progression_id, new_block_id) do
    Access.StudentProgressions.move_cursor_to(progression_id, new_block_id)
  end
end
