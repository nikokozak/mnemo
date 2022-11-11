defmodule MnemoWeb.Live.Subject.Editor do
  use MnemoWeb, :live_view
  alias Mnemo.Access.Schemas.{Subject}
  alias Mnemo.Managers.Course
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  def mount(%{"subject_id" => subject_id}, _session, socket) do
    subject =
      Subject
      |> Subject.where_id(subject_id)
      |> Subject.load_sections_with_blocks()
      |> PGRepo.one()

    {:ok, assign(socket, subject: subject, sections: subject.sections)}
  end

  # Subject Information Handlers

  def handle_event("save_information", %{"subject_information" => subject_info}, socket) do
    {:ok, updated_subject} = Course.save_subject(socket.assigns.subject.id, subject_info)

    {:noreply, assign(socket, subject: updated_subject)}
  end

  # Section Handlers

  def handle_event("new_section", _params, socket) do
    {:ok, new_section} = Course.new_section(socket.assigns.subject.id)

    new_section = new_section |> PGRepo.preload(:blocks)
    sections = socket.assigns.sections ++ [new_section]

    {:noreply, assign(socket, sections: sections)}
  end

  def handle_event("save_section", %{"section_information" => form_params}, socket) do
    section_id = form_params["section_id"]

    {:ok, updated_section} =
      Course.save_section(section_id, form_params)

    updated_sections =
      replace_section_while_keeping_blocks(socket.assigns.sections, updated_section)

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("delete_section", %{"section_id" => section_id}, socket) do
    {:ok, deleted} = Course.delete_section(section_id)

    sections = remove_section(socket.assigns.sections, deleted)

    {:noreply, assign(socket, sections: sections)}
  end

  # Block Handlers

  def handle_event("new_block", %{"section_id" => section_id, "type" => type}, socket) do
    {:ok, block} = Course.new_block(socket.assigns.subject.id, section_id, type)

    updated_sections =
      update_blocks_in_section(
        socket.assigns.sections,
        section_id,
        fn blocks -> blocks ++ [block] end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("delete_block", %{"section_id" => section_id, "block_id" => block_id}, socket) do
    {:ok, _block} = Course.delete_block(block_id)

    updated_sections =
      update_blocks_in_section(
        socket.assigns.sections,
        section_id,
        fn blocks -> Enum.filter(blocks, &(&1.id != block_id)) end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("add_content_brick", params, socket) do
    section_id = Map.fetch!(params, "section_id")
    block_id = Map.fetch!(params, "block_id")
    brick_type = Map.fetch!(params, "brick_type")

    block = get_block_from_assigns(socket, section_id, block_id)
    new_content_brick = %{"type" => brick_type, "content" => ""}

    # We can only add text bricks to FC and STATIC
    {:ok, updated_block} =
      case block.type do
        "static" ->
          updated_content = block.static_content ++ [new_content_brick]
          Course.save_block(block, %{static_content: updated_content})
        "fc" ->
          case params["side"] do
            "front" ->
              updated_content = block.fc_front_content ++ [new_content_brick]
              Course.save_block(block, %{fc_front_content: updated_content})
            "back" ->
              updated_content = block.fc_back_content ++ [new_content_brick]
              Course.save_block(block, %{fc_back_content: updated_content})
          end
      end

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("update_content_brick", %{"brick_form" => brick_form}, socket) do
    section_id = Map.fetch!(brick_form, "section_id")
    block_id = Map.fetch!(brick_form, "block_id")
    brick_idx = Map.fetch!(brick_form, "brick_idx")
    content = Map.fetch!(brick_form, "content")

    block = get_block_from_assigns(socket, section_id, block_id)
    brick_idx = String.to_integer(brick_idx)

    {:ok, updated_block} =
      case block.type do
        "static" ->
          updated_content = update_brick_content(block.static_content, brick_idx, content)
          Course.save_block(block, %{static_content: updated_content})

        "fc" ->
          case brick_form["side"] do
            "front" ->
              updated_content = update_brick_content(block.fc_front_content, brick_idx, content)
              Course.save_block(block, %{fc_front_content: updated_content})

            "back" ->
              updated_content = update_brick_content(block.fc_back_content, brick_idx, content)
              Course.save_block(block, %{fc_back_content: updated_content})
          end
      end

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("update_block", %{"block_question_form" => block_question_form}, socket) do
    section_id = Map.fetch!(block_question_form, "section_id")
    block_id = Map.fetch!(block_question_form, "block_id")
    question = Map.fetch!(block_question_form, "question")

    block = get_block_from_assigns(socket, section_id, block_id)

    {:ok, updated_block} =
      case block.type do
        "mcq" ->
          Course.save_block(block, %{mcq_question_text: question})
        "fibq" ->
          Course.save_block(block, %{fibq_question_text_template: question})
        "saq" ->
          Course.save_block(block, %{saq_question_text: question})
      end

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("update_mcq_answer", %{"mcq_answer_form" => mcq_answer_form}, socket) do
    section_id = Map.fetch!(mcq_answer_form, "section_id")
    block_id = Map.fetch!(mcq_answer_form, "block_id")
    choice_key = Map.fetch!(mcq_answer_form, "choice_key")
    choice_text = Map.fetch!(mcq_answer_form, "choice_text")

    block = get_block_from_assigns(socket, section_id, block_id)

    updated_mcq_answer_choices =
      block.mcq_answer_choices
      |> update_in(
        [Access.filter(&match?(%{"key" => ^choice_key}, &1)), Access.key("text")],
        fn _old_text -> choice_text end
      )

    {:ok, updated_block} = Course.save_block(block, %{mcq_answer_choices: updated_mcq_answer_choices})

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("pick_mcq_answer_correct", params, socket) do
    section_id = Map.fetch!(params, "section_id")
    block_id = Map.fetch!(params, "block_id")
    choice_key = Map.fetch!(params, "choice_key")
    block = get_block_from_assigns(socket, section_id, block_id)

    {:ok, updated_block} = Course.save_block(block, %{mcq_answer_correct: choice_key})

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("add_mcq_answer_choice", params, socket) do
    section_id = Map.fetch!(params, "section_id")
    block_id = Map.fetch!(params, "block_id")
    block = get_block_from_assigns(socket, section_id, block_id)

    new_choice = %{"key" => nil, "text" => "Another answer"}

    updated_choices =
      (block.mcq_answer_choices ++ [new_choice])
      |> Enum.reduce({97, []}, fn choice, {letter_codepoint, result} ->
        {letter_codepoint + 1, [Map.put(choice, "key", <<letter_codepoint>>) | result]}
      end)
      |> elem(1)
      |> Enum.reverse()

    {:ok, updated_block} = Course.save_block(block, %{mcq_answer_choices: updated_choices})

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("delete_mcq_answer", params, socket) do
    section_id = Map.fetch!(params, "section_id")
    block_id = Map.fetch!(params, "block_id")
    choice_key = Map.fetch!(params, "choice_key")
    block = get_block_from_assigns(socket, section_id, block_id)

    updated_choices =
      block.mcq_answer_choices
      |> Enum.filter(&(&1["key"] != choice_key))
      |> Enum.reduce({97, []}, fn choice, {letter_codepoint, result} ->
        {letter_codepoint + 1, [Map.put(choice, "key", <<letter_codepoint>>) | result]}
      end)
      |> elem(1)
      |> Enum.reverse()

    {:ok, updated_block} = Course.save_block(block, %{mcq_answer_choices: updated_choices})

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("update_saq_answer_choice", %{"saq_answer_form" => saq_answer_form}, socket) do

    section_id = Map.fetch!(saq_answer_form, "section_id")
    block_id = Map.fetch!(saq_answer_form, "block_id")
    choice_idx = Map.fetch!(saq_answer_form, "choice_idx")
    choice_text = Map.fetch!(saq_answer_form, "choice_text")
    block = get_block_from_assigns(socket, section_id, block_id)

    updated_choices =
      block.saq_answer_choices
      |> update_in(
        [Access.at(String.to_integer(choice_idx)), Access.key("text")],
        fn _old_text -> choice_text end
      )

    {:ok, updated_block} = Course.save_block(block, %{saq_answer_choices: updated_choices})

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("add_saq_answer_choice", params, socket) do
    section_id = Map.fetch!(params, "section_id")
    block_id = Map.fetch!(params, "block_id")

    block = get_block_from_assigns(socket, section_id, block_id)

    new_choice = %{"text" => nil}

    updated_choices = block.saq_answer_choices ++ [new_choice]

    {:ok, updated_block} = Course.save_block(block, %{saq_answer_choices: updated_choices})

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("delete_saq_answer_choice", params, socket) do
    section_id = Map.fetch!(params, "section_id")
    block_id = Map.fetch!(params, "block_id")
    choice_idx = Map.fetch!(params, "choice_idx")
    block = get_block_from_assigns(socket, section_id, block_id)

    updated_choices =
      block.saq_answer_choices
      |> List.delete_at(String.to_integer(choice_idx))

    {:ok, updated_block} = Course.save_block(block, %{saq_answer_choices: updated_choices})

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  defp get_block_from_assigns(socket, section_id, block_id) do
    [[block]] =
      get_in(
        socket.assigns.sections,
        [
          Access.filter(&match?(%{id: ^section_id}, &1)),
          Access.key(:blocks),
          Access.filter(&match?(%{id: ^block_id}, &1))
        ]
      )

    block
  end

  defp update_brick_content(block_content_key, brick_idx, new_content) do
    update_in(
      block_content_key,
      [Access.at(brick_idx)],
      fn brick -> Map.put(brick, "content", new_content) end
    )
  end

  defp update_blocks_in_section(sections, section_id, update_fn) do
    sections
    |> update_in(
      [
        Access.filter(&match?(%{id: ^section_id}, &1)),
        Access.key(:blocks)
      ],
      &update_fn.(&1)
    )
  end

  defp update_block_in_section(sections, section_id, block_id, update_fn) do
    sections
    |> update_in(
      [
        Access.filter(&match?(%{id: ^section_id}, &1)),
        Access.key(:blocks),
        Access.filter(&match?(%{id: ^block_id}, &1))
      ],
      &update_fn.(&1)
    )
  end

  defp replace_section_while_keeping_blocks(sections, updated_section) do
    # TODO: this is kind of hacky, but avoids having to preload blocks every time.
    section_id = updated_section.id
    Enum.map(sections, fn
      %{id: ^section_id} = old_section ->
        Map.put(updated_section, :blocks, old_section.blocks)
      section -> section
    end)
  end

  defp remove_section(sections, section_to_remove) do
    Enum.filter(sections, fn section -> section.id != section_to_remove.id end)
  end
end