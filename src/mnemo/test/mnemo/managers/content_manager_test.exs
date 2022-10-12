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

    test "rejects duplicate enrollments" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      section = Fixtures.create!(:subject_section, %{subject_id: subject.id})
      content_block = Fixtures.create!(:content_block, %{subject_section_id: section.id})

      {:ok, student_progression} = Content.enroll(student.email, subject.id)
      {:error, error_changeset} = Content.enroll(student.email, subject.id)

      refute error_changeset.valid?

      assert %{
               errors: [
                 owner_id:
                   {_, [constraint: :unique, constraint_name: "owner_id_subject_id_unique_index"]}
               ]
             } = error_changeset
    end
  end

  describe "save_progress/2" do
    test "correctly updates cursors in student_progression" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      first_section = Fixtures.create!(:subject_section, %{subject_id: subject.id})

      first_content_block =
        Fixtures.create!(:content_block, %{subject_section_id: first_section.id})

      new_section = Fixtures.create!(:subject_section, %{subject_id: subject.id})
      new_content_block = Fixtures.create!(:content_block, %{subject_section_id: new_section.id})
      {:ok, student_progression} = Content.enroll(student.email, subject.id)

      assert {:ok, updated_progression} =
               Content.save_progress(
                 student.email,
                 subject.id,
                 new_section.id,
                 new_content_block.id
               )

      # TODO: We need to implement logic for ordering sections and blocks, both front and back-end.
      # TODO: API needs to distinguish between progressing in one block in a same section, 
      # a new block and a new section, and check that all blocks in a given section have been
      # completed before assigning the section as completed.
      # TODO: We potentially don't need the entire section, we can just check it from the block section_id
      # TODO: We have to build-in a global check for progressions inside the `delete` and `edit` methods of
      # our content manager to update subscribed progressions.
      assert updated_progression.content_block_cursor_id == new_content_block.id
      assert updated_progression.subject_section_cursor_id == new_section.id
      assert updated_progression.completed_sections == [first_section]
      assert updated_progression.completed_blocks == [first_content_block]
    end
  end
end
