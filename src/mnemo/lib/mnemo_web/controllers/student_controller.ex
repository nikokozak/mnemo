defmodule MnemoWeb.StudentController do
  use MnemoWeb, :controller
  alias Mnemo.Managers.Course
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
    student_id = nil

    {:ok, enrollment} = Course.new_enrollment(student_id, subject_id)

    conn
    |> redirect(
      to: Routes.live_path(MnemoWeb.Endpoint, MnemoWeb.Live.Subject.Viewer, enrollment.id)
    )
  end

  def unenroll(conn, %{"enrollment_id" => enrollment_id}) do
    _student_id = Application.fetch_env!(:mnemo, :test_student_id)

    {:ok, _enrollment} = Course.delete_enrollment(enrollment_id)

    conn
    |> redirect(to: Routes.student_path(conn, :index))
  end
end
