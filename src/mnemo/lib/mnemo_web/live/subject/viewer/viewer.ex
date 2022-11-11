defmodule MnemoWeb.Live.Subject.Viewer do
  use MnemoWeb, :live_view
  alias Mnemo.Access.Schemas.{Block, Enrollment}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Managers.Course

  @answer_attempts 3

  def mount(%{"enrollment_id" => enrollment_id}, _session, socket) do
    enrollment =
      Enrollment
      |> Enrollment.where_id(enrollment_id)
      |> Enrollment.load_subject_with_sections_and_blocks()
      |> Enrollment.load_cursor_with_section()
      |> PGRepo.one()

    {:ok,
     assign(socket,
       enrollment: enrollment,
       answer_status: nil,
       answer_attempts: [],
       answer_value: nil
     )}
  end

  def handle_event("move_cursor", %{"new_cursor_id" => new_cursor_id}, socket) do
    {:ok, enrollment} = Course.move_cursor_enrollment(socket.assigns.enrollment, new_cursor_id)

    new_cursor =
      Block
      |> Block.where_id(enrollment.block_cursor_id)
      |> PGRepo.one()
      |> PGRepo.preload(:section)

    # TODO: Again, kinda hacky to avoid preloading everything again.
    updated_enrollment = Map.put(socket.assigns.enrollment, :block_cursor, new_cursor)

    {:noreply, assign(socket, enrollment: updated_enrollment)}
  end

  def handle_event("answer_attempt", %{"answer_form" => answer_vals}, socket) do
    block_id = socket.assigns.enrollment.block_cursor.id

    {:ok, {is_correct?, details}} = Course.test_block(block_id, answer_vals)

    if is_correct? or length(socket.assigns.answer_attempts) == @answer_attempts - 1 do
      updated_enrollment = Course.consume_cursor_enrollment(socket.assigns.enrollment)

      {:noreply,
       assign(socket,
         enrollment: updated_enrollment,
         answer_status: nil,
         answer_attempts: [],
         answer_value: nil
       )}
    else
      {:noreply,
       assign(socket,
         answer_status: if(is_nil(details), do: is_correct?, else: details),
         answer_attempts: [answer_vals | socket.assigns.answer_attempts],
         answer_value: answer_vals
       )}
    end
  end

  def handle_event("answer_mcq", %{"answer-key" => answer_key}, socket) do
    block_id = socket.assigns.enrollment.block_cursor.id

    {:ok, {is_correct?, details}} = Course.test_block(block_id, answer_key)

    if is_correct? or length(socket.assigns.answer_attempts) == @answer_attempts - 1 do
      updated_enrollment = Course.consume_cursor_enrollment(socket.assigns.enrollment)

      {:noreply,
       assign(socket,
         enrollment: updated_enrollment,
         answer_status: nil,
         answer_attempts: [],
         answer_value: nil
       )}
    else
      {:noreply,
       assign(socket,
         answer_status: if(is_nil(details), do: is_correct?, else: details),
         answer_attempts: [answer_key | socket.assigns.answer_attempts],
         answer_value: answer_key
       )}
    end
  end
end
