defmodule ContentClientWeb.Router do
  use ContentClientWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ContentClientWeb do
    pipe_through :api
  end
end
