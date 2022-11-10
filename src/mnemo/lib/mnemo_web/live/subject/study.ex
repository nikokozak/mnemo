defmodule MnemoWeb.Live.Subject.Study do
  use MnemoWeb, :live_view
  alias Mnemo.Access.Schemas.{Subject, Section, Block, Enrollment}
  alias Mnemo.Engines.Block, as: BlockEngine
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  @answer_attempts 3

  def mount(%{"enrollment_id" => enrollment_id}, _session, socket) do
    enrollment =
      Enrollment
      |> Enrollment.where_id(enrollment_id)
      |> Enrollment.load_subject_with_sections_and_blocks()
      |> Enrollment.load_cursor_with_section()
      |> PGRepo.one()

    {:ok, assign(socket,
        enrollment: enrollment,
        answer_status: nil,
        answer_attempts: [],
        answer_value: nil
      )}
  end

  def handle_event("move_cursor", %{"new_cursor_id" => new_cursor_id}, socket) do
    enrollment =
      socket.assigns.enrollment
      |> Enrollment.new_cursor_changeset(new_cursor_id)
      |> PGRepo.update!()

    new_cursor =
      Block
      |> Block.where_id(enrollment.block_cursor_id)
      |> PGRepo.one()
      |> PGRepo.preload(:section)

    updated_enrollment =
      Map.put(socket.assigns.enrollment, :block_cursor, new_cursor)

    #TODO: Again, kinda hacky to avoid preloading everything again.
    {:noreply, assign(socket, enrollment: updated_enrollment)}
  end

  def handle_event("answer_attempt",
    %{"answer_form" => answer_vals}, socket) do

    block_id = socket.assigns.enrollment.block_cursor.id

    {:ok, {is_correct?, details}} = BlockEngine.test_block(block_id, answer_vals)

    if is_correct? or length(socket.assigns.answer_attempts) == @answer_attempts - 1 do
      next_block = Block.next_block(socket.assigns.enrollment.block_cursor)

      updated_enrollment =
        socket.assigns.enrollment
        |> Enrollment.consume_cursor_changeset()
        |> Enrollment.new_cursor_changeset(next_block)
        |> PGRepo.update!()
        |> PGRepo.preload(block_cursor: :section)

      {:noreply,
       assign(socket,
         enrollment: updated_enrollment,
         answer_status: nil,
         answer_attempts: [],
       answer_value: nil)}
    else
        {:noreply,
         assign(socket,
           answer_status: (if is_nil(details), do: is_correct?, else: details),
           answer_attempts: [answer_vals | socket.assigns.answer_attempts],
         answer_value: answer_vals)}
    end
  end

  def handle_event("answer_mcq", %{"answer-key" => answer_key}, socket) do
    block_id = socket.assigns.enrollment.block_cursor.id

    {:ok, {is_correct?, details}} = BlockEngine.test_block(block_id, answer_key)

    if is_correct? or length(socket.assigns.answer_attempts) == @answer_attempts - 1 do
      next_block = Block.next_block(socket.assigns.enrollment.block_cursor)

      updated_enrollment =
        socket.assigns.enrollment
        |> Enrollment.consume_cursor_changeset()
        |> Enrollment.new_cursor_changeset(next_block)
        |> PGRepo.update!()
        |> PGRepo.preload(block_cursor: :section)

      {:noreply,
       assign(socket,
         enrollment: updated_enrollment,
         answer_status: nil,
         answer_attempts: [],
       answer_value: nil)}
      else
        {:noreply,
         assign(socket,
           answer_status: (if is_nil(details), do: is_correct?, else: details),
           answer_attempts: [answer_key | socket.assigns.answer_attempts],
         answer_value: answer_key)}
    end

  end




end
