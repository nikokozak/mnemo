defmodule Mnemo.Utils.Scheduler do
  use Quantum, otp_app: :mnemo

  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.{ScheduledBlock, ReviewBlock}

  @doc """
  Resets all student's review queues. Does so by:
  - Add onto ReviewBlock any ScheduledBlocks set to review today.
  """
  def refresh_review_queues(date \\ Mnemo.Utils.Config.date()) do
    blocks_scheduled_for_today =
      ScheduledBlock
      |> ScheduledBlock.where_date(date)
      |> PGRepo.all()

    Enum.each(blocks_scheduled_for_today, fn scheduled_block ->
      %ReviewBlock{}
      |> ReviewBlock.create_changeset(%{
        student_id: scheduled_block.student_id,
        subject_id: scheduled_block.subject_id,
        block_id: scheduled_block.block_id
      })
      |> PGRepo.insert!()
    end)
  end

  def empty_review_queue() do
    review_queued_blocks = PGRepo.all(ReviewBlock)

    Enum.each(review_queued_blocks, fn review_block ->
      PGRepo.delete!(review_block)
    end)
  end
end
