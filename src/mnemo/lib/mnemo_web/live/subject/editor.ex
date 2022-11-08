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
      socket.assigns.sections
      |> update_in(
        [
          Access.filter(&match?(%{id: ^section_id}, &1)),
          Access.key(:blocks)
        ],
        &(&1 ++ [block])
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
      socket.assigns.sections
      |> update_in(
        [
          Access.filter(&match?(%{id: ^section_id}, &1)),
          Access.key(:blocks)
        ],
        &Enum.filter(&1, fn block -> block.id != block_id end)
      )

    {:noreply, assign(socket, sections: updated_sections)}
  end
end
