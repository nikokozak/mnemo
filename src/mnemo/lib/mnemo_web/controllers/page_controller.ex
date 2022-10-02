defmodule MnemoWeb.PageController do
  use MnemoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
