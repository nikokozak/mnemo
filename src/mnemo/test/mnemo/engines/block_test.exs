defmodule Mnemo.Engines.BlockTest do
  use Mnemo.DataCase
  alias Mnemo.Access.Schemas.{Enrollment, ReviewBlock}
  alias Test.Fixtures
  alias Mnemo.Engines.Block, as: BlockEngine
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  describe "next_block/2" do
    test "returns a review block on request" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section} = Fixtures.create(:section, %{subject_id: subject.id})
      {:ok, block_1} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, block_2} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, block_3} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, enrollment} = Fixtures.create(:enrollment, %{student_id: student.id, subject_id: subject.id})

      {:ok, review_block_1} = Fixtures.create(:review_block, %{student_id: student.id, subject_id: subject.id, block_id: block_1.id})
      {:ok, review_block_2} = Fixtures.create(:review_block, %{student_id: student.id, subject_id: subject.id, block_id: block_2.id})
      {:ok, _review_block_3} = Fixtures.create(:review_block, %{student_id: student.id, subject_id: subject.id, block_id: block_3.id})

      return_block_1 = BlockEngine.next_block(enrollment, "review")
      return_block_2 = BlockEngine.next_block(enrollment, "review")
      return_block_3 = BlockEngine.next_block(enrollment, "review")

      assert return_block_1.id == return_block_2.id and return_block_2.id == return_block_3.id
      assert return_block_1.id == review_block_1.id

      {:ok, _deleted} = review_block_1
      |> ReviewBlock.delete_changeset()
      |> PGRepo.delete()

      return_block_1 = BlockEngine.next_block(enrollment, "review")
      return_block_2 = BlockEngine.next_block(enrollment, "review")
      return_block_3 = BlockEngine.next_block(enrollment, "review")

      assert return_block_1.id == return_block_2.id and return_block_2.id == return_block_3.id
      assert return_block_1.id == review_block_2.id
    end

    test "returns a subject block on request" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section} = Fixtures.create(:section, %{subject_id: subject.id})
      {:ok, block_1} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, _block_2} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, _block_3} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, enrollment} = Fixtures.create(:enrollment, %{student_id: student.id, subject_id: subject.id})

      assert enrollment.block_cursor.id == block_1.id

      return_block_1 = BlockEngine.next_block(enrollment, "study")
      return_block_2 = BlockEngine.next_block(enrollment, "study")
      return_block_3 = BlockEngine.next_block(enrollment, "study")

      assert return_block_1.id == return_block_2.id and return_block_2.id == return_block_3.id
      assert return_block_1.id == enrollment.block_cursor.id
    end

    test "returns a new subject block if cursor is already completed" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section} = Fixtures.create(:section, %{subject_id: subject.id})
      {:ok, _block_1} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, block_2} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, _block_3} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, enrollment} = Fixtures.create(:enrollment, %{student_id: student.id, subject_id: subject.id})

      {:ok, enrollment} =
      enrollment
      |> Enrollment.consume_cursor_changeset()
      |> PGRepo.update()

      return_block_1 = BlockEngine.next_block(enrollment, "study")
      return_block_2 = BlockEngine.next_block(enrollment, "study")
      return_block_3 = BlockEngine.next_block(enrollment, "study")

      assert return_block_1.id == return_block_2.id and return_block_2.id == return_block_3.id
      refute return_block_1.id == enrollment.block_cursor.id
      assert return_block_1.id == block_2.id
    end
  end

  describe "next_block/1" do
    test "returns a review block first if any exist, otherwise returns a subject block" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section} = Fixtures.create(:section, %{subject_id: subject.id})
      {:ok, block_1} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, _block_2} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, _block_3} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, enrollment} = Fixtures.create(:enrollment, %{student_id: student.id, subject_id: subject.id})

      {:ok, review_block_1} = Fixtures.create(:review_block, %{student_id: student.id, subject_id: subject.id, block_id: block_1.id})

      {"review", return_block_1} = BlockEngine.next_block(enrollment)

      assert return_block_1.id == review_block_1.id

      {:ok, _deleted} = review_block_1
      |> ReviewBlock.delete_changeset()
      |> PGRepo.delete()

      {"study", return_block_1} = BlockEngine.next_block(enrollment)

      assert return_block_1.id == enrollment.block_cursor.id

      {:ok, review_block_1} = Fixtures.create(:review_block, %{student_id: student.id, subject_id: subject.id, block_id: block_1.id})

      {"review", return_block_1} = BlockEngine.next_block(enrollment)

      assert return_block_1.id == review_block_1.id
    end
  end

end
