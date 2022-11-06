defmodule MnemoWeb.StudentController do
  use MnemoWeb, :controller
  alias Mnemo.Access.Schemas.{Subject, Enrollment}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  def index(conn, _params) do
    student_id = Application.fetch_env!(:mnemo, :test_student_id)

    student_subjects =
      Subject
      |> Subject.where_student(student_id)
      |> PGRepo.all()

    student_enrollments =
      Enrollment
      |> Enrollment.where_student(student_id)
      |> Enrollment.load_subject()
      |> PGRepo.all()

    conn
    |> render("index.html", %{student_subjects: student_subjects, student_enrollments: student_enrollments})
  end

end
