defmodule MnemoWeb.Live.Components.EditBlocks do
  use Phoenix.Component

  embed_templates("edit_blocks/*")

  attr :block, :map, required: true
  attr :section, :map, required: true

  def static(assigns)

  attr :block, :map, required: true
  attr :section, :map, required: true

  def fibq(assigns)

  attr :block, :map, required: true
  attr :section, :map, required: true

  def mcq(assigns)

  attr :block, :map, required: true
  attr :section, :map, required: true

  def fc(assigns)

  attr :block, :map, required: true
  attr :section, :map, required: true

  def saq(assigns)

  def block(type, section, block) do
    assigns = %{section: section, block: block}

    case type do
      "static" -> static(assigns)
      "fibq" -> fibq(assigns)
      "mcq" -> mcq(assigns)
      "fc" -> fc(assigns)
      "saq" -> saq(assigns)
    end
  end
end
