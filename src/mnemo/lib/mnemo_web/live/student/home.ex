defmodule MnemoWeb.Live.Student.Home do
  use MnemoWeb, :live_view
  alias Mnemo.Access.Schemas.{Subject, Enrollment, ReviewBlock, ScheduledBlock}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Managers.Course

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

    num_student_review_blocks =
      ReviewBlock
      |> PGRepo.aggregate(:count, :id)

    {:ok,
     assign(socket,
       student_id: student_id,
       subjects: student_subjects,
       enrollments: student_enrollments,
       mock_date_offset: 0,
       mock_date: Mnemo.Utils.Config.date(),
       num_student_review_blocks: num_student_review_blocks
     )}
  end

  def handle_event("new_subject", _params, socket) do
    student_id = Application.get_env(:mnemo, :test_student_id)
    # student_id = nil

    {:ok, new_subject} = Course.new_subject(student_id)

    {:noreply,
     push_navigate(socket,
       to: Routes.live_path(MnemoWeb.Endpoint, MnemoWeb.Live.Subject.Editor, new_subject.id)
     )}
  end

  def handle_event("enroll", %{"subject_id" => subject_id}, socket) do
    # student_id = nil
    student_id = Application.get_env(:mnemo, :test_student_id)

    {:ok, enrollment} = Course.new_enrollment(student_id, subject_id)

    {:noreply,
     push_navigate(socket,
       to: Routes.live_path(MnemoWeb.Endpoint, MnemoWeb.Live.Subject.Viewer, enrollment.id)
     )}
  end

  def handle_event("unenroll", %{"enrollment_id" => enrollment_id}, socket) do
    {:ok, deleted_enrollment} = Course.delete_enrollment(enrollment_id)

    updated_enrollments =
      Enum.filter(
        socket.assigns.enrollments,
        fn enrollment ->
          enrollment.id != deleted_enrollment.id
        end
      )

    {:noreply,
     assign(socket,
       enrollments: updated_enrollments
     )}
  end

  def handle_event("increase_mock_date_offset", _, socket) do
    Mnemo.Utils.Config.set_date(Date.add(Mnemo.Utils.Config.date(), -1))
    reset_review_queues()

    {:noreply,
     assign(socket,
       mock_date: Mnemo.Utils.Config.date(),
       num_student_review_blocks: count_review_blocks()
     )}
  end

  def handle_event("decrease_mock_date_offset", _, socket) do
    Mnemo.Utils.Config.set_date(Date.add(Mnemo.Utils.Config.date(), 1))
    reset_review_queues()

    {:noreply,
     assign(socket,
       mock_date: Mnemo.Utils.Config.date(),
       num_student_review_blocks: count_review_blocks()
     )}
  end

  def handle_event("reset_mock_date_offset", _, socket) do
    Mnemo.Utils.Config.set_date(Date.utc_today())
    reset_review_queues()

    {:noreply,
     assign(socket,
       mock_date: Mnemo.Utils.Config.date(),
       num_student_review_blocks: count_review_blocks()
     )}
  end

  # DEBUG
  defp reset_review_queues() do
    Mnemo.Utils.Scheduler.empty_review_queue()
    Mnemo.Utils.Scheduler.refresh_review_queues()
  end

  # DEBUG
  defp count_review_blocks() do
    ReviewBlock
    |> PGRepo.aggregate(:count, :id)
  end
end
