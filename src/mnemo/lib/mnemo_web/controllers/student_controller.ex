defmodule MnemoWeb.StudentController do
  use MnemoWeb, :controller
  alias Mnemo.Managers

  def index(conn, _params) do
    student_subjects = Managers.Content.student_subjects("nikokozak@gmail.com")

    IO.inspect(student_subjects)

    conn
    |> assign(:student_subjects, student_subjects)
    |> render("index.html")
  end
end
