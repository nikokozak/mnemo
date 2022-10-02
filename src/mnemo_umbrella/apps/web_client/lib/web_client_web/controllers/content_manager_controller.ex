defmodule WebClientWeb.ContentManagerController do
  use WebClientWeb, :controller

  def add_user(conn, %{"email" => email}) do
    users = ContentManager.add_user(email)

    conn
    |> put_status(:created)
    |> json(%{userList: users})
  end

  def users(conn, _params) do
    users = ContentManager.all_users()

    conn
    |> put_status(:ok)
    |> json(%{userList: users})
  end
end
