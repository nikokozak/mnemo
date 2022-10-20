defmodule MnemoWeb.CommandController do
  use MnemoWeb, :controller
  alias Mnemo.Access.Schemas.{Subject, Section, Block, Enrollment}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Engines.Block, as: BlockEngine

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

  def test_block(conn, %{"block_id" => block_id, "answer" => answer}) do
    {:ok, correct?} = BlockEngine.test_block(block_id, answer)

    conn
    |> put_status(:ok)
    |> json(correct?)
  end

  def create_enrollment(conn, %{"student_id" => student_id, "subject_id" => subject_id}) do
    enrollment =
      %Enrollment{}
      |> Enrollment.create_changeset(%{student_id: student_id, subject_id: subject_id})
      |> PGRepo.insert!()
      |> PGRepo.preload(:subject)

    conn
    |> put_status(:created)
    |> render("enrollment.json", %{enrollment: enrollment})
  end

  def delete_enrollment(conn, %{"enrollment_id" => enrollment_id}) do
    {:ok, _enrollment} =
      Enrollment
      |> Enrollment.where_id(enrollment_id)
      |> PGRepo.one()
      |> Enrollment.delete_changeset()
      |> PGRepo.delete()

    conn
    |> send_resp(:ok, "")
  end

  def consume_cursor_enrollment(conn, %{"enrollment_id" => enrollment_id, "answers" => _answers}) do
    enrollment =
      Enrollment
      |> Enrollment.where_id(enrollment_id)
      |> Enrollment.load_completed_blocks()
      |> Enrollment.load_completed_sections()
      |> Enrollment.load_cursor_with_section()
      |> Enrollment.load_subject()
      |> PGRepo.one()

    next_block = Block.next_block(enrollment.block_cursor)

    updated_enrollment =
      enrollment
      |> Enrollment.consume_cursor_changeset()
      |> Enrollment.new_cursor_changeset(next_block)
      |> PGRepo.update!()
      |> PGRepo.preload(block_cursor: :section)

    conn
    |> put_status(:ok)
    |> render("updated_enrollment.json", %{enrollment: updated_enrollment})
  end

  def move_cursor_enrollment(conn, %{
        "enrollment_id" => enrollment_id,
        "new_cursor_id" => new_cursor_id
      }) do
    enrollment =
      Enrollment
      |> Enrollment.where_id(enrollment_id)
      |> Enrollment.load_cursor()
      |> PGRepo.one()
      |> Enrollment.new_cursor_changeset(new_cursor_id)
      |> PGRepo.update!()
      |> PGRepo.preload(block_cursor: :section)

    conn
    |> put_status(:ok)
    |> render("updated_enrollment.json", %{enrollment: enrollment})
  end
end
