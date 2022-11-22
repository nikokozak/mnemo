defmodule MnemoWeb.Live.Subject.Viewer do
  use MnemoWeb, :live_view
  alias Mnemo.Access.Schemas.{Block, Enrollment}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Managers.Course

  def mount(%{"enrollment_id" => enrollment_id}, _session, socket) do
    enrollment =
      Enrollment
      |> Enrollment.where_id(enrollment_id)
      |> Enrollment.load_subject_with_sections_and_blocks()
      |> Enrollment.load_cursor_with_section()
      |> PGRepo.one()

    {block_type, block} = Course.next_block(enrollment)

    {:ok,
     assign(socket,
       enrollment: enrollment,
       block: block,
       block_type: block_type,
       answer_status: nil,
       answer_attempts: [],
       answer_value: nil,
       fc_revealed: false
     )}
  end

  def handle_event("navigate_to_block", %{"block_id" => block_id}, socket) do
    view_block =
      Block
      |> Block.where_id(block_id)
      |> PGRepo.one()
      |> PGRepo.preload(:section)

    {:noreply, assign(socket, block: view_block, block_type: "study")}
  end

  def handle_event("answer_fibq", %{"answer_form" => answer_vals}, socket) do
    # Go from %{0 => "blue", 1 => "sky"} to ["blue, sky", ...]
    # TODO: standardize how we store answer attempts so that it can cover
    # all card answers. Maybe JSON? And attempts is just an integer?
    answer =
      Enum.map(answer_vals, fn {_k, answer} -> answer end)
      |> Enum.join(",")

    consume_block(socket, answer, answer_vals)
  end

  def handle_event("answer_saq", %{"answer_form" => %{"answer" => answer}}, socket) do
    consume_block(socket, answer, answer)
  end

  def handle_event("answer_mcq", %{"answer-key" => answer_key}, socket) do
    consume_block(socket, answer_key, answer_key)
  end

  def handle_event("answer_static", %{"answer" => answer}, socket) do
    consume_block(socket, answer, answer)
  end

  def handle_event("reveal_fc", _params, socket) do
    {:noreply, assign(socket, fc_revealed: true)}
  end

  defp consume_block(socket, answer, raw_answer) do
    %{
      enrollment: enrollment,
      block: block,
      block_type: block_type,
      answer_attempts: answer_attempts
    } = socket.assigns

    answer_attempts = [answer | answer_attempts]

    case Course.consume_block(enrollment, block, block_type, answer_attempts) do
      {:correct, {next_block_type, next_block, enrollment}} ->
        {:noreply,
         assign(socket,
           block_type: next_block_type,
           block: next_block,
           enrollment: enrollment,
           answer_status: nil,
           answer_attempts: [],
           answer_value: nil
         )}

      {:incorrect, details} ->
        {:noreply,
         assign(socket,
           answer_status: if(is_nil(details), do: false, else: details),
           answer_attempts: answer_attempts,
           answer_value: raw_answer
         )}
    end
  end
end
