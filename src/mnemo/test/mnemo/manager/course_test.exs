defmodule Mnemo.Manager.CourseTest do
  use Mnemo.DataCase
  alias Mnemo.Managers.Course
  alias Mnemo.Access.Schemas.{Subject, Block, Enrollment, Section}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Test.Fixtures

  describe "new_subject/1" do
    test "successfully creates a new subject" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, new_subject} = Course.new_subject(student.id)
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
      {:ok, new_section} = Course.new_section(new_subject.id)
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
      {:ok, new_block} = Course.new_block(new_subject.id, new_section.id, "static")
    end
  end

  describe "update_block/2" do
    test "successfully updates a block" do
      {:ok, student} = Fixtures.create(:student)
      new_title = "My new section title"
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
      {:ok, new_enrollment} = Course.new_enrollment(student.id, new_subject.id)
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
    end
  end
end
