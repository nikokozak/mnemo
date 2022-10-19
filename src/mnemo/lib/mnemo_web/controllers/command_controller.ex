defmodule MnemoWeb.CommandController do
  use MnemoWeb, :controller
  alias Mnemo.Access.Schemas.{Subject, Section}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  def create_subject(conn, %{"student_id" => student_id}) do
    {:ok, new_subject} =
      %Subject{}
      |> Subject.create_changeset(%{student_id: student_id})
      |> PGRepo.insert()

    new_subject = new_subject |> PGRepo.preload(sections: :blocks)

    conn
    |> put_status(:created)
    |> render("subject.json", %{subject: new_subject})
  end

  def create_section(conn, %{"subject_id" => subject_id, "type" => section_type}) do
    {:ok, new_section} =
      %Section{}
      |> Section.create_changeset(%{subject_id: subject_id, type: section_type})
      |> PGRepo.insert()

    new_section = new_section |> PGRepo.preload(:blocks)

    conn
    |> put_status(:created)
    |> render("section.json", %{section: new_section})
  end
end
