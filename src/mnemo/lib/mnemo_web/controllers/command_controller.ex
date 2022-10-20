defmodule MnemoWeb.CommandController do
  use MnemoWeb, :controller
  alias Mnemo.Access.Schemas.{Subject, Section, Block}
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

  def save_subject(conn, %{"subject_id" => subject_id} = params) do
    {:ok, _subject} =
      %Subject{id: subject_id}
      |> Subject.update_changeset(params)
      |> PGRepo.update()

    conn
    |> send_resp(:accepted, "")
  end

  def delete_subject(conn, %{"subject_id" => subject_id}) do
    {:ok, _subject} =
      %Subject{id: subject_id}
      |> Subject.delete_changeset()
      |> PGRepo.delete()

    conn
    |> send_resp(:ok, "")
  end

  def create_section(conn, %{"subject_id" => subject_id}) do
    {:ok, new_section} =
      %Section{}
      |> Section.create_changeset(%{subject_id: subject_id})
      |> PGRepo.insert()
      |> IO.inspect(label: "created section")

    new_section = new_section |> PGRepo.preload(:blocks)

    conn
    |> put_status(:created)
    |> render("section.json", %{section: new_section})
  end

  def delete_section(conn, %{"section_id" => section_id}) do
    section_to_delete =
      Section
      |> Section.where_id(section_id)
      |> PGRepo.one()

    {:ok, _deleted} =
      section_to_delete
      |> Section.delete_changeset()
      |> PGRepo.delete()

    conn
    |> send_resp(:ok, "")
  end

  def save_section(conn, %{"section_id" => section_id} = params) do
    {:ok, _section} =
      %Section{id: section_id}
      |> Section.update_changeset(params)
      |> PGRepo.update()

    conn
    |> send_resp(:accepted, "")
  end

  def create_block(conn, %{"section_id" => section_id, "subject_id" => subject_id, "type" => type}) do
    {:ok, block} =
      %Block{}
      |> Block.create_changeset(%{section_id: section_id, subject_id: subject_id, type: type})
      |> PGRepo.insert()

    conn
    |> put_status(:created)
    |> render("block.json", %{block: block})
  end

  def save_block(conn, %{"block_id" => block_id} = params) do
    {:ok, _block} =
      %Block{id: block_id}
      |> Block.update_changeset(params)
      |> PGRepo.update()

    Process.sleep(500)

    conn
    |> send_resp(:accepted, "")
  end

  def delete_block(conn, %{"block_id" => block_id}) do
    {:ok, _block} =
      Block
      |> Block.where_id(block_id)
      |> PGRepo.one()
      |> Block.delete_changeset()
      |> PGRepo.delete()

    conn
    |> send_resp(:ok, "")
  end
end
