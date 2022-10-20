defmodule MnemoWeb.CommandView do
  use MnemoWeb, :view

  def render("subject.json", %{subject: subject}) do
    %{id: subject.id}
  end

  def render("section.json", %{section: section}) do
    %{
      id: section.id,
      title: section.title,
      blocks: Enum.map(section.blocks, &MnemoWeb.ViewHelpers.filter_block_fields_by_type/1)
    }
  end

  def render("block.json", %{block: block}) do
    MnemoWeb.ViewHelpers.filter_block_fields_by_type(block)
  end
end
