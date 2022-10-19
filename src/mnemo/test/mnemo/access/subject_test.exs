defmodule Mnemo.Access.SubjectTest do
  use Mnemo.DataCase
  alias Mnemo.Access.Schemas.{Subject}
  alias Test.Fixtures

  test "successfully creates a subject" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, _subject} = Fixtures.create(:subject, %{student_id: student.id})
  end

  test "successfully removes a subject" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})

    {:ok, _subject} =
      subject
      |> Repo.delete()
  end

  test "successfully updates a subject" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})

    {:ok, subject} =
      subject
      |> Subject.update_changeset(%{title: "New title"})
      |> Repo.update()

    assert subject.title == "New title"
  end

  test "successfully loads nested blocks through sections" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
    {:ok, section} = Fixtures.create(:section, %{subject_id: subject.id})
    {:ok, _block} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})

    subject =
      Subject
      |> Subject.where_id(subject.id)
      |> Subject.load_sections_with_blocks()
      |> Repo.one()

    first_section = List.first(subject.sections)
    first_block = List.first(first_section.blocks)

    assert first_block.type == "static"
  end
end
