defmodule Mnemo.Manager.CourseTest do
  use Mnemo.DataCase
  alias Mnemo.Managers.Course
  alias Mnemo.Access.Schemas.{Subject, Block, Enrollment, Section, ReviewBlock}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Test.Fixtures

  describe "new_subject/1" do
    test "successfully creates a new subject" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, _new_subject} = Course.new_subject(student.id)
    end
  end

  describe "update_subject/2" do
    test "successfully updates a subject" do
      {:ok, student} = Fixtures.create(:student)
      new_title = "My new title"
      update_params = %{title: new_title}

      {:ok, new_subject} = Course.new_subject(student.id)
      {:ok, updated_subject} = Course.update_subject(new_subject.id, update_params)

      assert updated_subject.title == new_title
    end
  end

  describe "delete_subject/1" do
    test "successfully deletes a subject" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, new_subject} = Course.new_subject(student.id)
      {:ok, deleted_subject} = Course.delete_subject(new_subject.id)

      subject =
        Subject
        |> Subject.where_id(deleted_subject.id)
        |> PGRepo.one()

      assert is_nil(subject)
    end
  end

  describe "new_section/1" do
    test "successfully creates a new section" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, new_subject} = Course.new_subject(student.id)
      {:ok, _new_section} = Course.new_section(new_subject.id)
    end
  end

  describe "update_section/2" do
    test "successfully updates a section" do
      {:ok, student} = Fixtures.create(:student)
      new_title = "My new section title"
      update_params = %{title: new_title}
      {:ok, new_subject} = Course.new_subject(student.id)
      {:ok, new_section} = Course.new_section(new_subject.id)
      {:ok, updated_section} = Course.update_section(new_section.id, update_params)

      assert updated_section.title == new_title
    end
  end

  describe "delete_section/1" do
    test "successfully deletes a section" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, new_subject} = Course.new_subject(student.id)
      {:ok, new_section} = Course.new_section(new_subject.id)
      {:ok, deleted_section} = Course.delete_section(new_section.id)

      section =
        Section
        |> Section.where_id(deleted_section.id)
        |> PGRepo.one()

      assert is_nil(section)
    end
  end

  describe "new_block/3" do
    test "successfully creates a block" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, new_subject} = Course.new_subject(student.id)
      {:ok, new_section} = Course.new_section(new_subject.id)
      {:ok, _new_block} = Course.new_block(new_subject.id, new_section.id, "static")
    end
  end

  describe "update_block/2" do
    test "successfully updates a block" do
      {:ok, student} = Fixtures.create(:student)
      update_params = %{testable: true}
      {:ok, new_subject} = Course.new_subject(student.id)
      {:ok, new_section} = Course.new_section(new_subject.id)
      {:ok, new_block} = Course.new_block(new_subject.id, new_section.id, "static")
      {:ok, updated_block} = Course.update_block(new_block, update_params)

      assert updated_block.testable
    end
  end

  describe "delete_block/1" do
    test "successfully deletes a block" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, new_subject} = Course.new_subject(student.id)
      {:ok, new_section} = Course.new_section(new_subject.id)
      {:ok, new_block} = Course.new_block(new_subject.id, new_section.id, "static")
      {:ok, deleted_block} = Course.delete_block(new_block.id)

      block =
        Block
        |> Block.where_id(deleted_block.id)
        |> PGRepo.one()

      assert is_nil(block)
    end
  end

  describe "new_enrollment/2" do
    test "successfully creates an enrollment" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, new_subject} = Course.new_subject(student.id)
      {:ok, _new_enrollment} = Course.new_enrollment(student.id, new_subject.id)
    end
  end

  describe "delete_enrollment/1" do
    test "successfully deletes an enrollment" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, new_subject} = Course.new_subject(student.id)
      {:ok, new_enrollment} = Course.new_enrollment(student.id, new_subject.id)
      {:ok, deleted_enrollment} = Course.delete_enrollment(new_enrollment.id)

      enrollment =
        Enrollment
        |> Enrollment.where_id(deleted_enrollment.id)
        |> PGRepo.one()

      assert is_nil(enrollment)
    end
  end

  describe "consume_block/4" do
    test "correctly removes a review block from the review queue" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section} = Fixtures.create(:section, %{subject_id: subject.id})
      {:ok, block_1} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, _block_2} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, _block_3} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})

      {:ok, enrollment} =
        Fixtures.create(:enrollment, %{student_id: student.id, subject_id: subject.id})

      {:ok, review_block_1} =
        Fixtures.create(:review_block, %{
          student_id: student.id,
          subject_id: subject.id,
          block_id: block_1.id
        })

      {:correct, {_type, _next_block, _enrollment}} =
        Course.consume_block(enrollment, block_1, "review", ["true"])

      assert is_nil(ReviewBlock |> ReviewBlock.where_id(review_block_1.id) |> PGRepo.one())
    end

    test "correctly returns a new review block from the review queue if more are left" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section} = Fixtures.create(:section, %{subject_id: subject.id})
      {:ok, block_1} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, block_2} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, _block_3} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})

      {:ok, enrollment} =
        Fixtures.create(:enrollment, %{student_id: student.id, subject_id: subject.id})

      {:ok, _review_block_1} =
        Fixtures.create(:review_block, %{
          student_id: student.id,
          subject_id: subject.id,
          block_id: block_1.id
        })

      {:ok, review_block_2} =
        Fixtures.create(:review_block, %{
          student_id: student.id,
          subject_id: subject.id,
          block_id: block_2.id
        })

      {:correct, {type, next_block, _enrollment}} =
        Course.consume_block(enrollment, block_1, "review", ["true"])

      assert type == "review"
      assert next_block.id == review_block_2.id
    end

    test "returns nil if no new review blocks and no new study blocks" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section} = Fixtures.create(:section, %{subject_id: subject.id})
      {:ok, block_1} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, block_2} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, block_3} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})

      {:ok, enrollment} =
        Fixtures.create(:enrollment, %{student_id: student.id, subject_id: subject.id})

      {:ok, _review_block_1} =
        Fixtures.create(:review_block, %{
          student_id: student.id,
          subject_id: subject.id,
          block_id: block_1.id
        })

      {:ok, _review_block_2} =
        Fixtures.create(:review_block, %{
          student_id: student.id,
          subject_id: subject.id,
          block_id: block_2.id
        })

      {:correct, {"review", _next_block, enrollment}} =
        Course.consume_block(enrollment, block_1, "review", ["true"])

      {:correct, {"study", _next_block, enrollment}} =
        Course.consume_block(enrollment, block_2, "review", ["true"])

      {:correct, {"study", _next_block, enrollment}} =
        Course.consume_block(enrollment, block_1, "study", ["true"])

      {:correct, {"study", _next_block, enrollment}} =
        Course.consume_block(enrollment, block_2, "study", ["true"])

      {:correct, {"study", next_block, enrollment}} =
        Course.consume_block(enrollment, block_3, "study", ["true"])

      assert is_nil(next_block)

      {:ok, block_1} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, block_2} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})

      {:ok, _review_block_1} =
        Fixtures.create(:review_block, %{
          student_id: student.id,
          subject_id: subject.id,
          block_id: block_1.id
        })

      {:ok, _review_block_2} =
        Fixtures.create(:review_block, %{
          student_id: student.id,
          subject_id: subject.id,
          block_id: block_2.id
        })

      {:correct, {"review", _next_block, enrollment}} =
        Course.consume_block(enrollment, block_1, "review", ["true"])

      {:correct, {"study", _next_block, enrollment}} =
        Course.consume_block(enrollment, block_2, "review", ["true"])

      {:correct, {"study", _next_block, enrollment}} =
        Course.consume_block(enrollment, block_1, "study", ["true"])

      {:correct, {"study", next_block, _enrollment}} =
        Course.consume_block(enrollment, block_2, "study", ["true"])

      assert is_nil(next_block)
    end

    @tag :skip
    test "does not return new review blocks if past the daily review limit, instead returns study blocks" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section} = Fixtures.create(:section, %{subject_id: subject.id})
      {:ok, block_1} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, _block_2} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, _block_3} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})

      {:ok, enrollment} =
        Fixtures.create(:enrollment, %{student_id: student.id, subject_id: subject.id})

      daily_limit = Application.fetch_env!(:mnemo, :daily_review_limit)

      # Create review blocks [0..daily_limit + 1]
      review_blocks =
        Enum.reduce(0..(daily_limit + 1), [], fn _, acc ->
          {:ok, review_block} =
            Fixtures.create(:review_block, %{
              student_id: student.id,
              subject_id: subject.id,
              block_id: block_1.id
            })

          [review_block | acc]
        end)

      # Exhaust our daily limit
      Enum.each(Enum.slice(review_blocks, 0, daily_limit - 1), fn rb ->
        {:correct, {_type, next_block, _enrollment}} =
          Course.consume_block(enrollment, rb.block_id, "review", ["true"])

        assert not is_nil(next_block)
      end)

      # We technically have one more left, but have exhausted daily limit previously.
      # Thus, return must be a "study" type
      {:correct, {type, next_block, _enrollment}} =
        Course.consume_block(enrollment, List.last(review_blocks), "review", ["true"])

      assert type == "study"
      assert next_block.id == block_1.id
    end
  end
end
