defmodule MnemoWeb.Live.Components.Modals do
  use Phoenix.Component

  embed_templates("modals/*")

  attr :button_text, :string, required: true
  attr :button_class, :string, default: nil
  slot(:icon)
  slot(:button_left)
  slot(:button_right)
  slot(:inner_block)

  def confirmation_modal(assigns)

  attr :button_text, :string, required: true
  attr :button_class, :string, default: nil
  slot(:icon)
  slot(:cancel_button)
  slot(:inner_block)
  slot(:modal_title)

  def general_modal(assigns)
end
