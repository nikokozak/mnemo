defmodule Mnemo.EnrollmentTest do
  use Mnemo.DataCase
  alias Mnemo.Access.Schemas.{Block, Section, Enrollment, Student, Subject}
  alias Test.Fixtures

  test "enrolls a student into a subject, with valid associations" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
    {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})
    {:ok, block_0} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

    {:ok, enrollment} =
      %Enrollment{}
      |> Enrollment.create_changeset(%{student_id: student.id, subject_id: subject.id})
      |> Repo.insert()

    assert enrollment.student_id == student.id
    assert enrollment.subject_id == subject.id
    assert enrollment.block_cursor_id == block_0.id
    assert enrollment.completed_sections == []
    assert enrollment.completed_blocks == []
    assert enrollment.completed == false
  end

  test "rejects duplicate enrollments" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})

    {:ok, _enrollment} =
      %Enrollment{}
      |> Enrollment.create_changeset(%{student_id: student.id, subject_id: subject.id})
      |> Repo.insert()

    {:error, chgst = %Ecto.Changeset{}} =
      %Enrollment{}
      |> Enrollment.create_changeset(%{student_id: student.id, subject_id: subject.id})
      |> Repo.insert()

    refute chgst.valid?
  end

  describe "consume_cursor_changeset/1" do
    test "correctly consumes cursor, adds cursor to completed cursors, and assigns nil at end" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})

      {:ok, block_0} =
        Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

      {:ok, _block_1} =
        Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

      {:ok, _block_2} =
        Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

      {:ok, enrollment} =
        %Enrollment{}
        |> Enrollment.create_changeset(%{student_id: student.id, subject_id: subject.id})
        |> Repo.insert()

      assert enrollment.block_cursor_id == block_0.id
      {:ok, enrollment} = enrollment |> Enrollment.consume_cursor_changeset() |> Repo.update()
      assert Enum.find_value(enrollment.completed_blocks, fn block -> block.id == block_0.id end)
      assert enrollment.block_cursor_id == nil
      {:ok, enrollment} = enrollment |> Enrollment.consume_cursor_changeset() |> Repo.update()
      assert enrollment.block_cursor_id == nil
    end

    test "correctly marks section as completed when all blocks have been consumed, and enrollment as completed" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})

      {:ok, block_0} =
        Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

      {:ok, block_1} =
        Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

      {:ok, block_2} =
        Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

      {:ok, enrollment} =
        %Enrollment{}
        |> Enrollment.create_changeset(%{student_id: student.id, subject_id: subject.id})
        |> Repo.insert()

      {:ok, enrollment} =
        enrollment
        |> Enrollment.consume_cursor_changeset()
        |> Enrollment.new_cursor_changeset(block_1.id)
        |> Repo.update()

      refute enrollment.completed

      refute Enum.find_value(enrollment.completed_sections, fn section ->
               section.id == section_0.id
             end)

      assert Enum.find_value(enrollment.completed_blocks, fn block -> block.id == block_0.id end)

      {:ok, enrollment} =
        enrollment
        |> Enrollment.consume_cursor_changeset()
        |> Enrollment.new_cursor_changeset(block_2.id)
        |> Repo.update()

      refute enrollment.completed

      refute Enum.find_value(enrollment.completed_sections, fn section ->
               section.id == section_0.id
             end)

      assert Enum.find_value(enrollment.completed_blocks, fn block -> block.id == block_1.id end)

      {:ok, enrollment} =
        enrollment
        |> Enrollment.consume_cursor_changeset()
        |> Repo.update()

      assert enrollment.completed

      assert Enum.find_value(enrollment.completed_sections, fn section ->
               section.id == section_0.id
             end)

      assert Enum.find_value(enrollment.completed_blocks, fn block -> block.id == block_2.id end)
    end
  end

  describe "handles deletions" do
    test "enrollment is deleted when student is deleted" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})

      {:ok, _block_0} =
        Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

      {:ok, enrollment} =
        %Enrollment{}
        |> Enrollment.create_changeset(%{student_id: student.id, subject_id: subject.id})
        |> Repo.insert()

      {:ok, _student} = student |> Student.delete_changeset() |> Repo.delete()

      refute Repo.get(Enrollment, enrollment.id)
    end

    test "enrollment is deleted when subject is deleted" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})

      {:ok, _block_0} =
        Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

      {:ok, enrollment} =
        %Enrollment{}
        |> Enrollment.create_changeset(%{student_id: student.id, subject_id: subject.id})
        |> Repo.insert()

      {:ok, _subject} = subject |> Subject.delete_changeset() |> Repo.delete()

      refute Repo.get(Enrollment, enrollment.id)
    end

    test "enrollment handles section deletions correctly" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})

      {:ok, _block_0} =
        Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

      {:ok, enrollment} =
        %Enrollment{}
        |> Enrollment.create_changeset(%{student_id: student.id, subject_id: subject.id})
        |> Repo.insert()

      {:ok, enrollment} =
        enrollment
        |> Enrollment.consume_cursor_changeset()
        |> Repo.update()

      {:ok, _section} = section_0 |> Section.delete_changeset() |> Repo.delete()

      assert Repo.get(Enrollment, enrollment.id)
    end

    test "block deletions are handled correctly" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})

      {:ok, block_0} =
        Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

      {:ok, _block_1} =
        Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

      {:ok, enrollment} =
        %Enrollment{}
        |> Enrollment.create_changeset(%{student_id: student.id, subject_id: subject.id})
        |> Repo.insert()

      {:ok, _block} = block_0 |> Block.delete_changeset() |> Repo.delete()

      updated_enrollment = Repo.get(Enrollment, enrollment.id) |> Repo.preload(:block_cursor)
      assert updated_enrollment.block_cursor == nil
    end

    test "enrollment is deleted correctly" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})

      {:ok, _block_0} =
        Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

      {:ok, enrollment} =
        %Enrollment{}
        |> Enrollment.create_changeset(%{student_id: student.id, subject_id: subject.id})
        |> Repo.insert()

      {:ok, enrollment} = enrollment |> Enrollment.delete_changeset() |> Repo.delete()

      refute Repo.get(Enrollment, enrollment.id)
    end
  end
end
