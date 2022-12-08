defmodule Mnemo.Utils.Scheduler do
  use Quantum, otp_app: :mnemo

  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.{ScheduledBlock, ReviewBlock}

  @doc """
  Resets all student's review queues. Does so by:
  - Add onto ReviewBlock any ScheduledBlocks set to review today.
  """
  def reset_review_queues do
    blocks_scheduled_for_today =
      ScheduledBlock
      |> ScheduledBlock.where_date(Date.utc_today())
      |> PGRepo.all()

    Enum.each(blocks_scheduled_for_today, fn block ->
      %ReviewBlock{}
      |> ReviewBlock.create_changeset(%{
        student_id: block.student_id,
        subject_id: block.subject_id,
        block_id: block.id
      })
      |> PGRepo.insert!()
    end)
  end
end
