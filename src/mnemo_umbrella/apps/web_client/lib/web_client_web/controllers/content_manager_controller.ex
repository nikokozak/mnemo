defmodule WebClientWeb.ContentManagerController do
  use WebClientWeb, :controller

  def add_user(conn, %{"email" => email}) do
    conn
    |> put_status(:created)
    |> json(%{userList: [email]})
  end
end
