defmodule Mnemo.Utils.SchedulerTest do
  use Mnemo.DataCase
  alias Mnemo.Access.Schemas.ReviewBlock
  alias Test.Fixtures
  alias Mnemo.Utils.Scheduler

  describe "refresh_review_queues/1" do
    test "adds today's scheduled blocks to the review queue" do
      {:ok, student} = Fixtures.create(:student)
      {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
      {:ok, section} = Fixtures.create(:section, %{subject_id: subject.id})
      {:ok, block_1} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, block_2} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})
      {:ok, block_3} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section.id})

      {:ok, scheduled_block_1} =
        Fixtures.create(:scheduled_block, %{
          student_id: student.id,
          subject_id: subject.id,
          block_id: block_1.id,
          review_at: Date.utc_today()
        })

      {:ok, scheduled_block_2} =
        Fixtures.create(:scheduled_block, %{
          student_id: student.id,
          subject_id: subject.id,
          block_id: block_2.id,
          review_at: Date.utc_today()
        })

      {:ok, scheduled_block_3} =
        Fixtures.create(:scheduled_block, %{
          student_id: student.id,
          subject_id: subject.id,
          block_id: block_3.id,
          review_at: Date.utc_today()
        })

      Scheduler.refresh_review_queues()

      review_block_1 = ReviewBlock |> ReviewBlock.where_block(scheduled_block_1)
      review_block_2 = ReviewBlock |> ReviewBlock.where_block(scheduled_block_2)
      review_block_3 = ReviewBlock |> ReviewBlock.where_block(scheduled_block_3)

      refute is_nil(review_block_1)
      refute is_nil(review_block_2)
      refute is_nil(review_block_3)
    end
  end
end
