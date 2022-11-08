defmodule MnemoWeb.Live.Subject.Components.Modals do
  use Phoenix.Component
  import Phoenix.HTML.Form, only: [submit: 2]
  alias MnemoWeb.Router.Helpers, as: Routes
  alias MnemoWeb.Live.Components.Modals

  embed_templates("templates/*")

  attr :socket, :map, required: true
  attr :subject, :map, required: true

  def deletion_modal(assigns)

  attr :section, :map, required: true

  def new_block_modal(assigns)
end
