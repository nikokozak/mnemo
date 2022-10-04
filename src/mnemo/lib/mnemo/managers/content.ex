defmodule Mnemo.Managers.Content do
  alias Mnemo.Access

  def create_student_subject(student_id) do
    Access.Subject.new_subject(student_id)
  end

  def delete_student_subject(subject_id) do
    Access.Subject.delete_subject(subject_id)
  end

  def student_subjects(student_id) do
    Access.Subject.student_subjects(student_id)
  end

  def subject(subject_id) do
    Access.Subject.subject(subject_id)
  end
end
