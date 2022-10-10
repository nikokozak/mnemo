defmodule MnemoWeb.APIController do
  use MnemoWeb, :controller

  def subjects(conn, %{"student_id" => email}) do
    subjects = Mnemo.Managers.Content.student_subjects(email)

    conn
    |> put_status(:ok)
    |> json(subjects)
  end

  def subject(conn, %{"subject_id" => subject_id}) do
    subject = Mnemo.Managers.Content.student_subject(subject_id)

    conn
    |> put_status(:ok)
    |> json(subject)
  end

  def create_subject(conn, %{"student_id" => email}) do
    {:ok, subject} = Mnemo.Managers.Content.create_student_subject(email)

    IO.inspect(subject, label: "created subject")

    conn
    |> put_status(:created)
    |> json(subject)
  end

  def save_subject(conn, %{"subject" => subject}) do
    {:ok, subject} = Mnemo.Managers.Content.save_student_subject(subject)

    conn
    |> put_status(:ok)
    |> json(subject)
  end

  def delete_subject(conn, %{"subject_id" => subject_id}) do
    {:ok, deleted_subject} = Mnemo.Managers.Content.delete_student_subject(subject_id)

    conn
    |> put_status(:accepted)
    |> json(deleted_subject)
  end

  def sections(conn, %{"subject_id" => subject_id}) do
    sections = Mnemo.Managers.Content.subject_sections(subject_id)

    conn
    |> put_status(:ok)
    |> json(sections)
  end

  def create_section(conn, %{"subject_id" => subject_id}) do
    {:ok, section} = Mnemo.Managers.Content.create_section(subject_id)

    conn
    |> put_status(:created)
    |> json(section)
  end

  def save_section(conn, %{"section" => section}) do
    {:ok, section} = Mnemo.Managers.Content.save_section(section)

    conn
    |> put_status(:ok)
    |> json(section)
  end

  def delete_section(conn, %{"section_id" => section_id}) do
    {:ok, deleted_section} = Mnemo.Managers.Content.delete_section(section_id)

    conn
    |> put_status(:accepted)
    |> json(deleted_section)
  end

  def content_blocks(conn, %{"section_id" => section_id}) do
    content_blocks = Mnemo.Managers.Content.content_blocks(section_id)

    conn
    |> put_status(:ok)
    |> json(content_blocks)
  end

  def content_block(conn, %{"content_block_id" => content_block_id}) do
    content_block = Mnemo.Managers.Content.content_block(content_block_id)

    conn
    |> put_status(:ok)
    |> json(content_block)
  end

  def create_content_block(conn, %{"section_id" => section_id, "type" => type}) do
    {:ok, content_block} = Mnemo.Managers.Content.create_content_block(section_id, type)

    conn
    |> put_status(:created)
    |> json(content_block)
  end

  def delete_content_block(conn, %{"content_block_id" => content_block_id}) do
    {:ok, content_block} = Mnemo.Managers.Content.delete_content_block(content_block_id)

    conn
    |> put_status(:accepted)
    |> json(content_block)
  end

  def save_content_block(conn, %{
        "content_block_id" => _content_block_id,
        "content_block" => content_block
      }) do
    {:ok, content_block} = Mnemo.Managers.Content.save_content_block(content_block)

    conn
    |> put_status(:ok)
    |> json(content_block)
  end

  def add_user(conn, %{"email" => email}) do
    users = Mnemo.Managers.Content.add_user(email)

    conn
    |> put_status(:created)
    |> json(%{userList: users})
  end

  def users(conn, _params) do
    users = Mnemo.Managers.Content.users()

    conn
    |> put_status(:ok)
    |> json(%{userList: users})
  end
end
