defmodule Mnemo.Managers.Content do
  def add_user(email) do
    Mnemo.Access.Subject.add_user(email)
  end

  def users() do
    Mnemo.Access.Subject.users()
  end

  def create_student_subject(student_id) do
    Mnemo.Access.Subject.create(student_id)
  end
end
