defmodule MnemoWeb.QueryView do
  use MnemoWeb, :view

  def render("study_page.json", %{enrollment: enrollment}) do
    cursor =
      if is_nil(enrollment.block_cursor) do
        nil
      else
        MnemoWeb.ViewHelpers.filter_block_fields_by_type(enrollment.block_cursor)
        |> Map.merge(%{
          section: %{
            id: enrollment.block_cursor.section.id,
            title: enrollment.block_cursor.section.title
          }
        })
      end

    subject_sections =
      enrollment.subject.sections
      |> Enum.map(fn section ->
        %{
          id: section.id,
          title: section.title,
          blocks:
            Enum.map(section.blocks, fn block ->
              %{id: block.id, type: block.type, order_in_section: block.order_in_section}
            end)
        }
      end)

    %{
      id: enrollment.id,
      block_cursor: cursor,
      subject: %{
        id: enrollment.subject.id,
        title: enrollment.subject.title,
        sections: subject_sections
      }
    }
  end

  def render("student_page.json", %{subjects: subjects, enrollments: enrollments}) do
    subjects = Enum.map(subjects, &Map.take(&1, [:id, :title, :published]))

    enrollments =
      Enum.map(enrollments, fn enrollment ->
        %{
          id: enrollment.id,
          subject: %{id: enrollment.subject_id, title: enrollment.subject.title}
        }
      end)

    %{subjects: subjects, enrollments: enrollments}
  end

  def render("subject.json", %{subject: subject}) do
    sections =
      Enum.map(subject.sections, fn section ->
        %{
          id: section.id,
          title: section.title,
          subject_id: section.subject_id,
          order_in_subject: section.order_in_subject,
          blocks: Enum.map(section.blocks, &MnemoWeb.ViewHelpers.filter_block_fields_by_type/1)
        }
      end)

    %{
      id: subject.id,
      title: subject.title,
      published: subject.published,
      private: subject.private,
      institution_only: subject.institution_only,
      price: subject.price,
      description: subject.description,
      sections: sections
    }
  end
end
