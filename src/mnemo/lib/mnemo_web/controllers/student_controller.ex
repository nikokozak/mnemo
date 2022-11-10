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
    |> render("index.html", %{
      student_subjects: student_subjects,
      student_enrollments: student_enrollments
    })
  end

  def enroll(conn, %{"subject_id" => subject_id}) do
    student_id = Application.fetch_env!(:mnemo, :test_student_id)

    {:ok, enrollment} =
      %Enrollment{}
      |> Enrollment.create_changeset(%{student_id: student_id, subject_id: subject_id})
      |> PGRepo.insert()

    conn
    |> redirect(
      to: Routes.live_path(MnemoWeb.Endpoint, MnemoWeb.Live.Subject.Study, enrollment.id)
    )
  end

  def unenroll(conn, %{"enrollment_id" => enrollment_id}) do
    student_id = Application.fetch_env!(:mnemo, :test_student_id)

    {:ok, _enrollment} =
      Enrollment
      |> Enrollment.where_id(enrollment_id)
      |> PGRepo.one()
      |> Enrollment.delete_changeset()
      |> PGRepo.delete()

    conn
    |> redirect(to: Routes.student_path(conn, :index))
  end
end
