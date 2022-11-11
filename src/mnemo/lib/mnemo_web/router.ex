defmodule MnemoWeb.Router do
  use MnemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MnemoWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MnemoWeb do
    pipe_through :browser

    get "/", StudentController, :index
    get "/enroll", StudentController, :enroll
    get "/unenroll", StudentController, :unenroll
  end

  scope "/study", MnemoWeb do
    pipe_through :browser

    live "/:enrollment_id", Live.Subject.Viewer
  end

  scope "/subject", MnemoWeb do
    pipe_through :browser

    post "/delete", SubjectController, :delete
    get "/new", SubjectController, :new
    live "/:subject_id", Live.Subject.Editor
  end

  # In general, /pages indicate initial-load GETS that cover 
  # all the content a given page might initially need
  scope "/api/pages", MnemoWeb do
    pipe_through :api

    get "/student/:student_id", QueryController, :get_student_page
    get "/study/:enrollment_id", QueryController, :get_study_page
  end

  scope "/api/subjects", MnemoWeb do
    pipe_through :api

    delete "/:subject_id", CommandController, :delete_subject
    patch "/:subject_id", CommandController, :save_subject
    get "/:subject_id", QueryController, :get_subject
    post "/", CommandController, :create_subject
  end

  scope "/api/sections", MnemoWeb do
    pipe_through :api

    delete "/:section_id", CommandController, :delete_section
    patch "/:section_id", CommandController, :save_section
    post "/", CommandController, :create_section
  end

  scope "/api/blocks", MnemoWeb do
    pipe_through :api

    post "/:block_id/test", CommandController, :test_block
    delete "/:block_id", CommandController, :delete_block
    patch "/:block_id", CommandController, :save_block
    post "/", CommandController, :create_block
  end

  scope "/api/enrollments", MnemoWeb do
    pipe_through :api

    post "/:enrollment_id/move", CommandController, :move_cursor_enrollment
    post "/:enrollment_id/consume", CommandController, :consume_cursor_enrollment
    delete "/:enrollment_id", CommandController, :delete_enrollment
    post "/", CommandController, :create_enrollment
  end

  # Other scopes may use custom stacks.
  # scope "/api", MnemoWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MnemoWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
