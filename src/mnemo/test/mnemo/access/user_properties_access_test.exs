defmodule Mnemo.Access.UserPropertiesTest do
  use Mnemo.DataCase
  alias Mnemo.Access.UserProperties

  test "new_student/1 successfully creates a new student" do
    {:ok, student} = UserProperties.new_student("test@email.com")
    assert student.email == "test@email.com"
  end

  test "new_student/1 rejects students with the same email" do
    {:ok, student} = UserProperties.new_student("test@email.com")

    assert_raise(Ecto.ConstraintError, fn ->
      {:ok, _student} = UserProperties.new_student(student.email)
    end)
  end

  test "students/0 retrieves all inserted students" do
    {:ok, student_1} = UserProperties.new_student("test_one@email.com")
    {:ok, student_2} = UserProperties.new_student("test_two@email.com")

    students = UserProperties.students()

    assert length(students) == 2
    assert student_1 in students
    assert student_2 in students
  end
end
