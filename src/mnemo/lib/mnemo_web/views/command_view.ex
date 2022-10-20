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

  # Returned after creation, usable only in "student" page - for 
  # full-fledged enrollment response, check QueryView.
  def render("enrollment.json", %{enrollment: enrollment}) do
    %{
      id: enrollment.id,
      subject: %{
        id: enrollment.subject.id,
        title: enrollment.subject.title
      }
    }
  end

  def render("updated_enrollment.json", %{enrollment: enrollment}) do
    block_cursor =
      if is_nil(enrollment.block_cursor) do
        nil
      else
        block_cursor_section = %{
          id: enrollment.block_cursor.section.id,
          title: enrollment.block_cursor.section.title
        }

        MnemoWeb.ViewHelpers.filter_block_fields_by_type(enrollment.block_cursor)
        |> Map.merge(%{section: block_cursor_section})
      end

    %{
      id: enrollment.id,
      block_cursor: block_cursor
    }
  end
end
