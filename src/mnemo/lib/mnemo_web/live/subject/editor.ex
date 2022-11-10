defmodule MnemoWeb.Live.Subject.Editor do
  use MnemoWeb, :live_view
  alias Mnemo.Access.Schemas.{Subject, Section, Block}
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
    {:ok, updated_subject} =
      %Subject{id: socket.assigns.subject.id}
      |> Subject.update_changeset(subject_info)
      |> PGRepo.update()

    {:noreply, assign(socket, subject: updated_subject)}
  end

  # Section Handlers

  def handle_event("new_section", _params, socket) do
    {:ok, new_section} =
      %Section{}
      |> Section.create_changeset(%{subject_id: socket.assigns.subject.id})
      |> PGRepo.insert()
      |> IO.inspect(label: "created section")

    new_section = new_section |> PGRepo.preload(:blocks)

    sections = socket.assigns.sections ++ [new_section]

    {:noreply, assign(socket, sections: sections)}
  end

  def handle_event(
        "save_section",
        %{"section_information" => %{"section_id" => section_id, "title" => title} = params},
        socket
      ) do
    {:ok, updated_section} =
      %Section{id: section_id}
      |> Section.update_changeset(params)
      |> PGRepo.update()

    updated_sections =
      Enum.map(socket.assigns.sections, fn
        # TODO: this is kind of hacky, but avoids having to preload blocks every time.
        %{id: ^section_id} = old_section -> Map.put(updated_section, :blocks, old_section.blocks)
        section -> section
      end)

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("delete_section", %{"section_id" => section_id}, socket) do
    section_to_delete =
      Section
      |> Section.where_id(section_id)
      |> PGRepo.one()

    {:ok, deleted} =
      section_to_delete
      |> Section.delete_changeset()
      |> PGRepo.delete()

    sections = Enum.filter(socket.assigns.sections, fn section -> section.id != deleted.id end)

    {:noreply, assign(socket, sections: sections)}
  end

  # Block Handlers

  def handle_event("new_block", %{"section_id" => section_id, "type" => type}, socket) do
    {:ok, block} =
      %Block{}
      |> Block.create_changeset(%{
        section_id: section_id,
        subject_id: socket.assigns.subject.id,
        type: type
      })
      |> PGRepo.insert()

    updated_sections =
      update_blocks_in_section(
        socket.assigns.sections,
        section_id,
        fn blocks -> blocks ++ [block] end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("delete_block", %{"section_id" => section_id, "block_id" => block_id}, socket) do
    {:ok, _block} =
      Block
      |> Block.where_id(block_id)
      |> PGRepo.one()
      |> Block.delete_changeset()
      |> PGRepo.delete()

    updated_sections =
      update_blocks_in_section(
        socket.assigns.sections,
        section_id,
        fn blocks -> Enum.filter(blocks, &(&1.id != block_id)) end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event(
        "add_content_brick",
        %{"section_id" => section_id, "block_id" => block_id, "brick_type" => brick_type} =
          params,
        socket
      ) do
    [[block]] =
      get_in(
        socket.assigns.sections,
        [
          Access.filter(&match?(%{id: ^section_id}, &1)),
          Access.key(:blocks),
          Access.filter(&match?(%{id: ^block_id}, &1))
        ]
      )

    new_content_brick = %{"type" => brick_type, "content" => ""}

    # We can only add text bricks to FC and STATIC
    {:ok, updated_block} =
      case block.type do
        "static" ->
          updated_content = block.static_content ++ [new_content_brick]

          block
          |> Block.update_changeset(%{static_content: updated_content})
          |> PGRepo.update()

        "fc" ->
          case params["side"] do
            "front" ->
              updated_content = block.fc_front_content ++ [new_content_brick]

              block
              |> Block.update_changeset(%{fc_front_content: updated_content})
              |> PGRepo.update()

            "back" ->
              updated_content = block.fc_back_content ++ [new_content_brick]

              block
              |> Block.update_changeset(%{fc_back_content: updated_content})
              |> PGRepo.update()
          end
      end

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event(
        "update_content_brick",
        %{
          "brick_form" =>
            %{
              "section_id" => section_id,
              "block_id" => block_id,
              "brick_idx" => brick_idx,
              "content" => content
            } = params
        },
        socket
      ) do
    block = get_block_from_assigns(socket, section_id, block_id)

    brick_idx = String.to_integer(brick_idx)

    {:ok, updated_block} =
      case block.type do
        "static" ->
          updated_content =
            update_in(
              block.static_content,
              [Access.at(brick_idx)],
              fn brick -> Map.put(brick, "content", content) end
            )

          block
          |> Block.update_changeset(%{static_content: updated_content})
          |> PGRepo.update()

        "fc" ->
          case params["side"] do
            "front" ->
              updated_content =
                update_in(
                  block.fc_front_content,
                  [Access.at(brick_idx)],
                  fn brick -> Map.put(brick, "content", content) end
                )

              block
              |> Block.update_changeset(%{fc_front_content: updated_content})
              |> PGRepo.update()

            "back" ->
              updated_content =
                update_in(
                  block.fc_back_content,
                  [Access.at(brick_idx)],
                  fn brick -> Map.put(brick, "content", content) end
                )

              block
              |> Block.update_changeset(%{fc_back_content: updated_content})
              |> PGRepo.update()
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

  def handle_event(
        "update_block",
        %{
          "block_question_form" => %{
            "section_id" => section_id,
            "block_id" => block_id,
            "question" => question
          }
        },
        socket
      ) do
    block = get_block_from_assigns(socket, section_id, block_id)

    {:ok, updated_block} =
      case block.type do
        "mcq" ->
          block
          |> Block.update_changeset(%{mcq_question_text: question})
          |> PGRepo.update()

        "fibq" ->
          block
          |> Block.update_changeset(%{fibq_question_text_template: question})
          |> PGRepo.update()

        "saq" ->
          block
          |> Block.update_changeset(%{saq_question_text: question})
          |> PGRepo.update()
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

  def handle_event(
        "update_mcq_answer",
        %{
          "mcq_answer_form" => %{
            "section_id" => section_id,
            "block_id" => block_id,
            "choice_key" => choice_key,
            "choice_text" => choice_text
          }
        },
        socket
      ) do
    block = get_block_from_assigns(socket, section_id, block_id)

    updated_mcq_answer_choices =
      block.mcq_answer_choices
      |> update_in(
        [Access.filter(&match?(%{"key" => ^choice_key}, &1)), Access.key("text")],
        fn _old_text -> choice_text end
      )

    {:ok, updated_block} =
      block
      |> Block.update_changeset(%{mcq_answer_choices: updated_mcq_answer_choices})
      |> PGRepo.update()

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event(
        "pick_mcq_answer_correct",
        %{"section_id" => section_id, "block_id" => block_id, "choice_key" => choice_key},
        socket
      ) do
    block = get_block_from_assigns(socket, section_id, block_id)

    {:ok, updated_block} =
      block
      |> Block.update_changeset(%{mcq_answer_correct: choice_key})
      |> PGRepo.update()

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event(
        "add_mcq_answer_choice",
        %{"section_id" => section_id, "block_id" => block_id},
        socket
      ) do
    block = get_block_from_assigns(socket, section_id, block_id)

    new_choice = %{"key" => nil, "text" => "Another answer"}

    updated_choices =
      (block.mcq_answer_choices ++ [new_choice])
      |> Enum.reduce({97, []}, fn choice, {letter_codepoint, result} ->
        {letter_codepoint + 1, [Map.put(choice, "key", <<letter_codepoint>>) | result]}
      end)
      |> elem(1)
      |> Enum.reverse()

    {:ok, updated_block} =
      block
      |> Block.update_changeset(%{mcq_answer_choices: updated_choices})
      |> PGRepo.update()

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event(
        "delete_mcq_answer",
        %{"section_id" => section_id, "block_id" => block_id, "choice_key" => choice_key},
        socket
      ) do
    block = get_block_from_assigns(socket, section_id, block_id)

    updated_mcq_answer_choices =
      block.mcq_answer_choices
      |> Enum.filter(&(&1["key"] != choice_key))
      |> Enum.reduce({97, []}, fn choice, {letter_codepoint, result} ->
        {letter_codepoint + 1, [Map.put(choice, "key", <<letter_codepoint>>) | result]}
      end)
      |> elem(1)
      |> Enum.reverse()

    {:ok, updated_block} =
      block
      |> Block.update_changeset(%{mcq_answer_choices: updated_mcq_answer_choices})
      |> PGRepo.update()

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event(
        "update_saq_answer_choice",
        %{
          "saq_answer_form" => %{
            "section_id" => section_id,
            "block_id" => block_id,
            "choice_idx" => answer_idx,
            "choice_text" => choice_text
          }
        },
        socket
      ) do
    block = get_block_from_assigns(socket, section_id, block_id)

    updated_saq_answer_choices =
      block.saq_answer_choices
      |> update_in(
        [Access.at(String.to_integer(answer_idx)), Access.key("text")],
        fn _old_text -> choice_text end
      )

    {:ok, updated_block} =
      block
      |> Block.update_changeset(%{saq_answer_choices: updated_saq_answer_choices})
      |> PGRepo.update()

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event(
        "add_saq_answer_choice",
        %{"section_id" => section_id, "block_id" => block_id},
        socket
      ) do
    block = get_block_from_assigns(socket, section_id, block_id)

    new_choice = %{"text" => nil}

    updated_choices = block.saq_answer_choices ++ [new_choice]

    {:ok, updated_block} =
      block
      |> Block.update_changeset(%{saq_answer_choices: updated_choices})
      |> PGRepo.update()

    updated_sections =
      update_block_in_section(
        socket.assigns.sections,
        section_id,
        block_id,
        fn _old_block -> updated_block end
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event(
        "delete_saq_answer_choice",
        %{"section_id" => section_id, "block_id" => block_id, "choice_idx" => choice_idx},
        socket
      ) do
    block = get_block_from_assigns(socket, section_id, block_id)

    updated_saq_answer_choices =
      block.saq_answer_choices
      |> List.delete_at(String.to_integer(choice_idx))

    {:ok, updated_block} =
      block
      |> Block.update_changeset(%{saq_answer_choices: updated_saq_answer_choices})
      |> PGRepo.update()

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
end
