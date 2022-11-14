defmodule MnemoWeb.Live.Components.StudyBlocks do
  use Phoenix.Component
  import Phoenix.HTML.Form
  import Phoenix.HTML.Tag

  embed_templates("study_blocks/*")

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

  def block(type, block, answer_status, answer_value, fc_revealed) do
    assigns = %{block: block, answer_status: answer_status, answer_value: answer_value, fc_revealed: fc_revealed}

    case type do
      "static" -> static(assigns)
      "fibq" -> fibq(assigns)
      "mcq" -> mcq(assigns)
      "fc" -> fc(assigns)
      "saq" -> saq(assigns)
    end
  end
end
