defmodule MnemoWeb.Live.Components.Global do
  use Phoenix.Component
  import Phoenix.HTML.Form

  embed_templates("global/*")

  attr :uploads_field, :map, required: true
  attr :image_url, :string, required: true
  def image_upload(assigns)
end
