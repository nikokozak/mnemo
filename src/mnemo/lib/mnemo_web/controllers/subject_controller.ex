defmodule MnemoWeb.SubjectController do
  use MnemoWeb, :controller
  alias Mnemo.Managers.Course

  def new(conn, _params) do
    student_id = nil

    {:ok, new_subject} = Course.new_subject(student_id)

    conn
    |> redirect(
      to: Routes.live_path(MnemoWeb.Endpoint, MnemoWeb.Live.Subject.Editor, new_subject.id)
    )
  end

  def delete(conn, %{"subject_id" => subject_id}) do
    {:ok, _deleted_subject} = Course.delete_subject(subject_id)

    conn
    |> redirect(to: Routes.student_path(conn, :index))
  end
end
