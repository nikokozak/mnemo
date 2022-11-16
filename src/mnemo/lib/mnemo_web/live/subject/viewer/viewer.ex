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
       # subject | review
       block_type: :subject,
       answer_status: nil,
       answer_attempts: [],
       answer_value: nil,
       fc_revealed: false
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

    {:noreply, assign(socket, enrollment: updated_enrollment, block_type: :subject)}
  end

  def handle_event("answer_fibq", %{"answer_form" => answer_vals}, socket) do
    block_id = socket.assigns.enrollment.block_cursor.id

    # Go from %{0 => "blue", 1 => "sky"} to ["blue, sky", ...]
    # TODO: standardize how we store answer attempts so that it can cover
    # all card answers. Maybe JSON? And attempts is just an integer?
    answers =
      Enum.map(answer_vals, fn {_k, answer} -> answer end)
      |> Enum.join(",")

    answer_attempts = [answers | socket.assigns.answer_attempts]

    {:ok, {is_correct?, details}} = Course.test_block(block_id, answer_vals)

    if is_correct? or length(socket.assigns.answer_attempts) == @answer_attempts - 1 do
      updated_enrollment =
        Course.consume_cursor_enrollment(socket.assigns.enrollment, is_correct?, answer_attempts)

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
         answer_attempts: answer_attempts,
         answer_value: answer_vals
       )}
    end
  end

  def handle_event("answer_saq", %{"answer_form" => %{"answer" => answer}}, socket) do
    block_id = socket.assigns.enrollment.block_cursor.id
    answer_attempts = [answer | socket.assigns.answer_attempts]

    {:ok, {is_correct?, details}} = Course.test_block(block_id, answer)

    if is_correct? or length(socket.assigns.answer_attempts) == @answer_attempts - 1 do
      updated_enrollment =
        Course.consume_cursor_enrollment(socket.assigns.enrollment, is_correct?, answer_attempts)

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
         answer_attempts: answer_attempts,
         answer_value: answer
       )}
    end
  end

  def handle_event("answer_mcq", %{"answer-key" => answer_key}, socket) do
    block_id = socket.assigns.enrollment.block_cursor.id
    answer_attempts = [answer_key | socket.assigns.answer_attempts]

    {:ok, {is_correct?, details}} = Course.test_block(block_id, answer_key)

    if is_correct? or length(socket.assigns.answer_attempts) == @answer_attempts - 1 do
      updated_enrollment =
        Course.consume_cursor_enrollment(socket.assigns.enrollment, is_correct?, answer_attempts)

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
         answer_attempts: answer_attempts,
         answer_value: answer_key
       )}
    end
  end

  def handle_event("answer_static", %{"answer" => answer}, socket) do
    block_id = socket.assigns.enrollment.block_cursor.id
    answer_attempts = [answer]

    {:ok, {is_correct?, _details}} = Course.test_block(block_id, answer)

    updated_enrollment =
      Course.consume_cursor_enrollment(socket.assigns.enrollment, is_correct?, answer_attempts)

    {:noreply,
     assign(socket,
       enrollment: updated_enrollment,
       answer_status: nil,
       answer_attempts: [],
       answer_value: nil,
       fc_revealed: false
     )}
  end

  def handle_event("reveal_fc", _params, socket) do
    {:noreply, assign(socket, fc_revealed: true)}
  end
end
