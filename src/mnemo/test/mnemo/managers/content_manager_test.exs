defmodule Mnemo.Managers.ContentTest do
  use Mnemo.DataCase
  alias Mnemo.Managers.Content
  alias Test.Fixtures

  describe "create_section/1" do
    test "successfully creates a section" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})

      {:ok, subject_section} = Content.create_section(subject.id)
    end

    test "successfully auto-increments section order on creation" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})

      {:ok, subject_section} = Content.create_section(subject.id)
      {:ok, subject_section_2} = Content.create_section(subject.id)

      assert subject_section.order_in_subject == 0
      assert subject_section_2.order_in_subject == 1
    end
  end

  describe "enroll/2" do
    test "enrolls a student into a subject, with valid associations" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      section = Fixtures.create!(:subject_section, %{subject_id: subject.id})
      content_block = Fixtures.create!(:content_block, %{subject_section_id: section.id})

      {:ok, student_progression} = Content.enroll(student.email, subject.id)

      assert student_progression.owner_id == student.email
      assert student_progression.subject_id == subject.id
      assert student_progression.content_block_cursor_id == content_block.id
      assert student_progression.completed_sections == []
      assert student_progression.completed_blocks == []
    end

    test "rejects duplicate enrollments" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      section = Fixtures.create!(:subject_section, %{subject_id: subject.id})
      _content_block = Fixtures.create!(:content_block, %{subject_section_id: section.id})

      {:ok, _student_progression} = Content.enroll(student.email, subject.id)
      {:error, :already_enrolled} = Content.enroll(student.email, subject.id)
    end
  end

  describe "save_progress/2" do
    test "correctly updates cursors in student_progression" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      {:ok, first_section} = Content.create_section(subject.id)

      {:ok, first_content_block} = Content.create_content_block(first_section.id, "static")

      {:ok, new_section} = Content.create_section(subject.id)
      {:ok, new_content_block} = Content.create_content_block(new_section.id, "static")

      {:ok, _student_progression} = Content.enroll(student.email, subject.id)

      assert {:ok, updated_progression} =
               Content.save_progress(
                 student.email,
                 subject.id,
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
      assert updated_progression.completed_sections == [first_section]
      assert updated_progression.completed_blocks == [first_content_block]
    end
  end

  describe "reorder_subject_section/2" do
    test "correctly updates section order when shifting up" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      {:ok, first_section} = Content.create_section(subject.id)
      {:ok, second_section} = Content.create_section(subject.id)
      {:ok, third_section} = Content.create_section(subject.id)

      assert first_section.order_in_subject == 0
      assert second_section.order_in_subject == 1
      assert third_section.order_in_subject == 2

      assert {:ok, _multi} = Content.reorder_subject_section(first_section.id, 2)

      first_section_updated = Content.subject_section(first_section.id)
      second_section_updated = Content.subject_section(second_section.id)
      third_section_updated = Content.subject_section(third_section.id)

      assert first_section_updated.order_in_subject == 2
      assert second_section_updated.order_in_subject == 0
      assert third_section_updated.order_in_subject == 1
    end

    test "correctly updates section order when shifting down" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      {:ok, first_section} = Content.create_section(subject.id)
      {:ok, second_section} = Content.create_section(subject.id)
      {:ok, third_section} = Content.create_section(subject.id)

      assert first_section.order_in_subject == 0
      assert second_section.order_in_subject == 1
      assert third_section.order_in_subject == 2

      assert {:ok, _multi} = Content.reorder_subject_section(third_section.id, 0)

      first_section_updated = Content.subject_section(first_section.id)
      second_section_updated = Content.subject_section(second_section.id)
      third_section_updated = Content.subject_section(third_section.id)

      assert first_section_updated.order_in_subject == 1
      assert second_section_updated.order_in_subject == 2
      assert third_section_updated.order_in_subject == 0
    end

    test "ignores a shift into its same index" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      {:ok, first_section} = Content.create_section(subject.id)
      {:ok, second_section} = Content.create_section(subject.id)
      {:ok, third_section} = Content.create_section(subject.id)

      assert first_section.order_in_subject == 0
      assert second_section.order_in_subject == 1
      assert third_section.order_in_subject == 2

      assert {:ok, _multi} = Content.reorder_subject_section(third_section.id, 2)

      first_section_updated = Content.subject_section(first_section.id)
      second_section_updated = Content.subject_section(second_section.id)
      third_section_updated = Content.subject_section(third_section.id)

      assert first_section_updated.order_in_subject == 0
      assert second_section_updated.order_in_subject == 1
      assert third_section_updated.order_in_subject == 2
    end
  end

  # TODO: Tests are randomly failing, changing orders. Something's up with the
  # transaction or the Multi.
  # ANSWER: MAKE SURE YOU ORDER BY ORDER_IN_SECTION WHEN YOU FETCH, BEFORE REDUCE
  # SEE: https://groups.google.com/g/elixir-ecto/c/e3DFZUyB4aw
  # Maybe have to lock rows during transactions.
  describe "reorder_content_block/2" do
    test "correctly updates block order when shifting up" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      {:ok, section} = Content.create_section(subject.id)
      {:ok, first_content_block} = Content.create_content_block(section.id, "static")
      {:ok, second_content_block} = Content.create_content_block(section.id, "static")
      {:ok, third_content_block} = Content.create_content_block(section.id, "static")

      assert first_content_block.order_in_section == 0
      assert second_content_block.order_in_section == 1
      assert third_content_block.order_in_section == 2

      assert {:ok, _multi} = Content.reorder_content_block(first_content_block.id, 2)

      first_content_block_updated = Content.content_block(first_content_block.id)
      second_content_block_updated = Content.content_block(second_content_block.id)
      third_content_block_updated = Content.content_block(third_content_block.id)

      assert first_content_block_updated.order_in_section == 2
      assert second_content_block_updated.order_in_section == 0
      assert third_content_block_updated.order_in_section == 1
    end

    test "correctly updates block order when shifting down" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      {:ok, section} = Content.create_section(subject.id)
      {:ok, first_content_block} = Content.create_content_block(section.id, "static")
      {:ok, second_content_block} = Content.create_content_block(section.id, "static")
      {:ok, third_content_block} = Content.create_content_block(section.id, "static")

      assert first_content_block.order_in_section == 0
      assert second_content_block.order_in_section == 1
      assert third_content_block.order_in_section == 2

      assert {:ok, _multi} = Content.reorder_content_block(third_content_block.id, 0)

      first_content_block_updated = Content.content_block(first_content_block.id)
      second_content_block_updated = Content.content_block(second_content_block.id)
      third_content_block_updated = Content.content_block(third_content_block.id)

      assert first_content_block_updated.order_in_section == 1
      assert second_content_block_updated.order_in_section == 2
      assert third_content_block_updated.order_in_section == 0
    end

    test "ignores a shift into its same index" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      {:ok, section} = Content.create_section(subject.id)
      {:ok, first_content_block} = Content.create_content_block(section.id, "static")
      {:ok, second_content_block} = Content.create_content_block(section.id, "static")
      {:ok, third_content_block} = Content.create_content_block(section.id, "static")

      assert first_content_block.order_in_section == 0
      assert second_content_block.order_in_section == 1
      assert third_content_block.order_in_section == 2

      assert {:ok, _multi} = Content.reorder_content_block(third_content_block.id, 2)

      first_content_block_updated = Content.content_block(first_content_block.id)
      second_content_block_updated = Content.content_block(second_content_block.id)
      third_content_block_updated = Content.content_block(third_content_block.id)

      assert first_content_block_updated.order_in_section == 0
      assert second_content_block_updated.order_in_section == 1
      assert third_content_block_updated.order_in_section == 2
    end
  end

  describe "reorder_content_block/3" do
    test "correctly updates new block order when inserting into new section" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      {:ok, section_0} = Content.create_section(subject.id)
      {:ok, section_0_cb_0} = Content.create_content_block(section_0.id, "static")
      {:ok, section_0_cb_1} = Content.create_content_block(section_0.id, "static")
      {:ok, section_0_cb_2} = Content.create_content_block(section_0.id, "static")
      {:ok, section_1} = Content.create_section(subject.id)
      {:ok, section_1_cb_0} = Content.create_content_block(section_1.id, "static")
      {:ok, section_1_cb_1} = Content.create_content_block(section_1.id, "static")
      {:ok, section_1_cb_2} = Content.create_content_block(section_1.id, "static")

      assert section_0_cb_0.order_in_section == 0
      assert section_0_cb_0.subject_section_id == section_0.id
      assert section_1_cb_0.order_in_section == 0
      assert section_1_cb_0.subject_section_id == section_1.id

      assert {:ok, _multi} = Content.reorder_content_block(section_0_cb_1.id, 1, section_1.id)

      section_1_cb_0_updated = Content.content_block(section_1_cb_0.id)
      section_1_cb_1_updated = Content.content_block(section_1_cb_1.id)
      section_1_cb_2_updated = Content.content_block(section_1_cb_2.id)
      section_0_cb_1_updated = Content.content_block(section_0_cb_1.id)

      assert section_1_cb_0_updated.order_in_section == 0
      assert section_1_cb_1_updated.order_in_section == 2
      assert section_1_cb_2_updated.order_in_section == 3
      assert section_0_cb_1_updated.order_in_section == 1
      assert section_0_cb_1_updated.subject_section_id == section_1.id
    end

    test "correctly updates blocks from old section when inserted into new section" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      {:ok, section_0} = Content.create_section(subject.id)
      {:ok, section_0_cb_0} = Content.create_content_block(section_0.id, "static")
      {:ok, section_0_cb_1} = Content.create_content_block(section_0.id, "static")
      {:ok, section_0_cb_2} = Content.create_content_block(section_0.id, "static")
      {:ok, section_1} = Content.create_section(subject.id)
      {:ok, section_1_cb_0} = Content.create_content_block(section_1.id, "static")
      {:ok, section_1_cb_1} = Content.create_content_block(section_1.id, "static")
      {:ok, section_1_cb_2} = Content.create_content_block(section_1.id, "static")

      assert {:ok, _multi} = Content.reorder_content_block(section_0_cb_1.id, 1, section_1.id)

      section_0_cb_0_updated = Content.content_block(section_0_cb_0.id)
      section_0_cb_2_updated = Content.content_block(section_0_cb_2.id)
      section_0_cb_1_updated = Content.content_block(section_0_cb_1.id)

      assert section_0_cb_0_updated.order_in_section == 0
      assert section_0_cb_2_updated.order_in_section == 1
      assert section_0_cb_1_updated.order_in_section == 1
      assert section_0_cb_1_updated.subject_section_id == section_1.id
    end
  end

  describe "delete_section/1" do
    test "correctly deletes a section" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      {:ok, section_0} = Content.create_section(subject.id)

      {:ok, deleted_section} = Content.delete_section(section_0.id)

      assert Content.subject_section(deleted_section.id) == nil
    end

    test "correctly deletes student_progressions if no sections left" do
      student = Fixtures.create!(:student)
      subject = Fixtures.create!(:subject, %{owner_id: student.email})
      {:ok, section_0} = Content.create_section(subject.id)
      {:ok, section_0_cb_0} = Content.create_content_block(section_0.id, "static")
      {:ok, student_progression} = Content.enroll(student.email, subject.id)

      {:ok, deleted_section} = Content.delete_section(section_0.id)
      updated_student_progression = Content.student_progression(student_progression.id)

      assert updated_student_progression.content_block_cursor == nil
    end
  end
end
