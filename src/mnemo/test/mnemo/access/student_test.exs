defmodule Mnemo.StudentTest do
  use Mnemo.DataCase
  alias Mnemo.Access.Schemas.Student

  test "successfully creates a new student" do
    {:ok, student} =
      %Student{} |> Student.create_changeset(%{email: "test@email.com"}) |> Repo.insert()

    assert student.email == "test@email.com"
  end

  test "rejects students with the same email" do
    {:ok, student} =
      %Student{} |> Student.create_changeset(%{email: "test@email.com"}) |> Repo.insert()

    assert_raise(Ecto.ConstraintError, fn ->
      {:ok, _student} =
        %Student{} |> Student.create_changeset(%{email: "test@email.com"}) |> Repo.insert()
    end)
  end
end
