defmodule MnemoWeb.QueryView do
  use MnemoWeb, :view

  def render("subject.json", %{subject: subject}) do
    sections =
      Enum.map(subject.sections, fn section ->
        %{
          id: section.id,
          title: section.title,
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

  def render("student_page.json", %{subjects: subjects, enrollments: enrollments}) do
    subjects = Enum.map(subjects, &Map.take(&1, [:id, :title, :published]))

    enrollments =
      Enum.map(enrollments, fn enrollment ->
        %{id: enrollment.id, subject_id: enrollment.subject_id, title: enrollment.subject.title}
      end)

    %{subjects: subjects, enrollments: enrollments}
  end
end
