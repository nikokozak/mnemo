defmodule Mnemo.Managers.Content do
  alias Mnemo.Access

  def enroll(student_id, subject_id) do
    Access.StudentProgressions.create(student_id, subject_id)
  end

  def save_progress(student_id, subject_id, new_section_id, new_block_id) do
    Access.StudentProgressions.save(student_id, subject_id, new_section_id, new_block_id)
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
    Access.Subjects.sections(subject_id)
  end

  def create_section(subject_id) do
    Access.SubjectSections.create(subject_id)
  end

  def save_section(section) do
    Access.SubjectSections.save(section)
  end

  def delete_section(section_id) do
    Access.SubjectSections.delete(section_id)
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

  def delete_content_block(content_block_id) do
    Access.ContentBlocks.delete(content_block_id)
  end

  def reorder_content_block(content_block_id, new_idx, new_section_idx) do
  end

  def reorder_content_block(content_block_id, new_idx) do
  end
end
