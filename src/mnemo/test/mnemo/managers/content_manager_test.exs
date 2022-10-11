defmodule Mnemo.Managers.ContentTest do
  use Mnemo.DataCase
  alias Mnemo.Managers.Content
  alias Test.Fixtures

  describe "enroll/2" do
    test "enrolls a student into a subject, with valid associations" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      section = Fixtures.create!(:subject_section, %{subject_id: subject.id})
      content_block = Fixtures.create!(:content_block, %{subject_section_id: section.id})

      {:ok, student_progression} = Content.enroll(student.email, subject.id)

      assert student_progression.owner_id == student.email
      assert student_progression.subject_id == subject.id
      assert student_progression.subject_section_cursor_id == section.id
      assert student_progression.content_block_cursor_id == content_block.id
      assert student_progression.completed_sections == []
      assert student_progression.completed_blocks == []
    end
  end
end
