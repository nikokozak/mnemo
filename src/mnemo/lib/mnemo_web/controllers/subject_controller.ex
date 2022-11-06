defmodule MnemoWeb.SubjectController do
  use MnemoWeb, :controller
  alias Mnemo.Access.Schemas.Subject
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  def new(conn, _params) do
    student_id = Application.fetch_env!(:mnemo, :test_student_id)

    {:ok, new_subject} =
      %Subject{}
      |> Subject.create_changeset(%{student_id: student_id})
      |> PGRepo.insert()

    conn
    |> redirect(to: Routes.live_path(MnemoWeb.Endpoint, MnemoWeb.Live.Subject.Editor, new_subject.id))
  end

  def delete(conn, %{"subject_id" => subject_id}) do
    student_id = Application.fetch_env!(:mnemo, :test_student_id)

    {:ok, deleted_subject} =
      %Subject{id: subject_id}
      |> Subject.delete_changeset()
      |> PGRepo.delete()

    conn
    |> redirect(to: Routes.student_path(conn, :index))
  end

end
