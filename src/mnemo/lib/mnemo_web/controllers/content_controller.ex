defmodule MnemoWeb.ContentController do
  use MnemoWeb, :controller
  alias Mnemo.Managers

  def create(conn, _params) do
    {:ok, new_subject} = Managers.Content.create_student_subject("nikokozak@gmail.com")

    conn
    |> redirect(to: Routes.content_path(conn, :edit, new_subject.id))
  end

  def edit(conn, %{"subject_id" => subject_id}) do
    subject = Managers.Content.student_subject(subject_id)

    conn
    |> assign(:subject, subject)
    |> render("edit.html")
  end

  def delete(conn, %{"subject_id" => subject_id}) do
    {:ok, _deleted_subject} = Managers.Content.delete_student_subject(subject_id)

    conn
    |> redirect(to: Routes.student_path(conn, :index))
  end

  def save(conn, subject) do
    Managers.Content.save_student_subject(subject)

    conn
    |> put_status(:created)
    |> json(%{status: :ok})
  end
end
