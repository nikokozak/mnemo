defmodule MnemoWeb.QueryController do
  use MnemoWeb, :controller
  alias Mnemo.Access.Schemas.{Subject, Enrollment}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  # Returns a fully preloaded enrollment, as well as details on a "nav"
  # section
  def get_study_page(conn, %{"enrollment_id" => enrollment_id}) do
    enrollment =
      Enrollment
      |> Enrollment.where_id(enrollment_id)
      |> Enrollment.load_subject_with_sections_and_blocks()
      |> Enrollment.load_cursor_with_section()
      |> PGRepo.one()

    conn
    |> put_status(:ok)
    |> render("study_page.json", %{enrollment: enrollment})
  end

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
