defmodule MnemoWeb.QueryController do
  use MnemoWeb, :controller
  alias Mnemo.Access.Schemas.{Student, Subject, Enrollment}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  def get_student_page(conn, %{"student_id" => student_id}) do
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
    |> put_status(:ok)
    |> render("student_page.json", %{subjects: student_subjects, enrollments: student_enrollments})
  end

  def get_subject(conn, %{"subject_id" => subject_id}) do
    subject =
      Subject
      |> Subject.where_id(subject_id)
      |> Subject.load_sections_with_blocks()
      |> PGRepo.one()

    conn
    |> put_status(:ok)
    |> render("subject.json", %{subject: subject})
  end
end
