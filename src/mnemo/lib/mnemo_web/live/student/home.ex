defmodule MnemoWeb.Live.Student.Home do
  use Phoenix.LiveView
  alias Mnemo.Access.Schemas.{Subject, Enrollment}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  def mount(_params, _session, socket) do
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

    {:ok,
     assign(socket,
       student_subjects: student_subjects,
       student_enrollments: student_enrollments)}
  end

end
