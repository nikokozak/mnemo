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
        %{id: ^section_id} -> updated_section
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
          fn blocks -> blocks ++ [block] end)

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
        fn blocks -> Enum.filter(blocks, &(&1.id != block_id)) end)

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("add_content_brick",
    %{"section_id" => section_id,
      "block_id" => block_id,
      "brick_type" => brick_type} = params, socket) do


    [[block]] = get_in(socket.assigns.sections,
      [Access.filter(&match?(%{id: ^section_id}, &1)),
       Access.key(:blocks),
       Access.filter(&match?(%{id: ^block_id}, &1))])

    new_content_brick = %{ "type" => brick_type, "content" => "" }

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
        fn old_block -> updated_block end)

    {:noreply, assign(socket, sections: updated_sections)}
  end

  def handle_event("update_content_brick",
    %{"brick_form" => %{"section_id" => section_id,
                        "block_id" => block_id,
                        "brick_idx" => brick_idx,
                        "content" => content} = params}, socket) do

    [[block]] = get_in(socket.assigns.sections,
      [Access.filter(&match?(%{id: ^section_id}, &1)),
       Access.key(:blocks),
       Access.filter(&match?(%{id: ^block_id}, &1))])

    brick_idx = String.to_integer(brick_idx)

    {:ok, updated_block} =
      case block.type do
        "static" ->
          updated_content =
            update_in(block.static_content,
              [Access.at(brick_idx)],
              fn brick -> Map.put(brick, "content", content) end)

          block
          |> Block.update_changeset(%{static_content: updated_content})
          |> PGRepo.update()
        "fc" ->
          case params["side"] do
            "front" ->
              updated_content =
                update_in(block.fc_front_content,
                  [Access.at(brick_idx)],
                  fn brick -> Map.put(brick, "content", content) end)

              block
              |> Block.update_changeset(%{fc_front_content: updated_content})
              |> PGRepo.update()
            "back" ->
              updated_content =
                update_in(block.fc_back_content,
                  [Access.at(brick_idx)],
                  fn brick -> Map.put(brick, "content", content) end)

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
              fn old_block ->
                IO.inspect(old_block)
                updated_block end)

    {:noreply, assign(socket, sections: updated_sections)}
  end

  defp update_blocks_in_section(sections, section_id, update_fn) do
    sections
    |> update_in(
      [
        Access.filter(&match?(%{id: ^section_id}, &1)),
        Access.key(:blocks)
      ],
    &update_fn.(&1))
  end

  defp update_block_in_section(sections, section_id, block_id, update_fn) do
    sections
    |> update_in(
      [
        Access.filter(&match?(%{id: ^section_id}, &1)),
        Access.key(:blocks),
        Access.filter(&match?(%{id: ^block_id}, &1))
      ],
    &update_fn.(&1))
  end
end
