defmodule MnemoWeb.Live.Subject.Editor do
  use MnemoWeb, :live_view
  alias Mnemo.Access.Schemas.{Subject}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  def mount(%{"subject_id" => subject_id}, _session, socket) do
    subject =
      Subject
      |> Subject.where_id(subject_id)
      |> Subject.load_sections_with_blocks()
      |> PGRepo.one()

    {:ok, assign(socket, subject: subject)}
  end

  def handle_event("save_information",
    %{"subject_information" => subject_info}, socket) do

    {:ok, updated_subject} =
      %Subject{id: socket.assigns.subject.id}
      |> Subject.update_changeset(subject_info)
      |> PGRepo.update()

    {:noreply, assign(socket, subject: updated_subject)}
  end

end
