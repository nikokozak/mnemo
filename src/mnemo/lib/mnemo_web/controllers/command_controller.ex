defmodule MnemoWeb.CommandController do
  use MnemoWeb, :controller
  alias Mnemo.Access.Schemas.{Subject}
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
end
