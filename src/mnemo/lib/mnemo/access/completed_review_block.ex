defmodule Mnemo.Access.Schemas.CompletedReviewBlock do
  use Mnemo.Access.Schemas.Schema
  alias Mnemo.Access.Schemas.{Subject, Block, Student}

  @derive {Jason.Encoder,
           only: [
             :id,
             :student_id,
             :subject_id,
             :block_id,
             :succeeded,
             :answers,
             :correct_in_a_row,
             :interval_to_next_review,
             :easyness,
             :time_taken,
             :date_suggested,
             :date_completed
           ]}

  schema "student_completed_reviews" do
    belongs_to :student, Student, on_replace: :delete
    belongs_to :subject, Subject, on_replace: :delete
    belongs_to :block, Block, on_replace: :delete

    field :succeeded, :boolean
    field :answers, {:array, :string}

    field :correct_in_a_row, :integer, default: 0
    field :interval_to_next_review, :integer
    field :easyness, :decimal, default: 2.5

    field :time_taken, :integer
    field :date_suggested, :date
    field :date_completed, :date
  end

  def where_id(query \\ __MODULE__, block_id), do: from(cb in query, where: cb.id == ^block_id)

  def where_subject(query \\ __MODULE__, subject_id),
    do: from(cb in query, where: cb.subject_id == ^subject_id)

  def where_block(query \\ __MODULE__, block_id),
    do: from(cb in query, where: cb.block_id == ^block_id)

  def where_date(query \\ __MODULE__, date),
    do: from(cb in query, where: cb.review_at == ^date)

  def where_succeeded(query \\ __MODULE__, succeeded),
    do: from(cb in query, where: cb.succeeded == ^succeeded)

  def where_date_suggested(query \\ __MODULE__, date_suggested),
    do: from(cb in query, where: cb.date_suggested == ^date_suggested)

  def where_date_completed(query \\ __MODULE__, date_completed),
    do: from(cb in query, where: cb.date_completed == ^date_completed)

  def create_changeset(
        completed_block,
        %{
          student_id: _student_id,
          subject_id: _subject_id,
          block_id: _block_id,
          succeeded: _succeeded,
          answers: _answers,
          time_taken: _time_taken
        } = params
      ) do
    completed_block
    |> cast(params, ~w(
        student_id
        subject_id
        block_id
        succeeded
        answers
        time_taken
        date_suggested
        date_completed)a)
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:subject_id)
    |> foreign_key_constraint(:block_id)
    |> maybe_increase_correct_in_a_row_count()
    |> assign_interval_and_easyness()
  end

  def delete_changeset(scheduled_block) do
    # TODO: redundant?
    scheduled_block
    |> cast(%{}, [])
  end

  def maybe_increase_correct_in_a_row_count(changeset) do
    if get_change(changeset, :succeeded) do
      correct_in_a_row = get_field(changeset, :correct_in_a_row) || -1

      changeset
      |> put_change(:correct_in_a_row, correct_in_a_row + 1)
    else
      changeset
      |> put_change(:correct_in_a_row, 0)
    end
  end

  def assign_interval_and_easyness(changeset) do
    changeset
    |> assign_interval_til_next_review()
    |> assign_easyness_value()
  end

  defp assign_interval_til_next_review(changeset) do
    success? = get_change(changeset, :succeeded)
    correct_in_a_row = get_change(changeset, :correct_in_a_row)
    easyness = get_field(changeset, :easyness) || 2.5

    interval_til_next_review =
      Mnemo.Engines.Scheduling.review_interval(success?, correct_in_a_row, easyness)

    put_change(changeset, :interval_to_next_review, interval_til_next_review)
  end

  defp assign_easyness_value(changeset) do
    answer_attempts = length(get_change(changeset, :answers))
    new_easyness = Mnemo.Engines.Scheduling.easyness(answer_attempts)
    put_change(changeset, :easyness, new_easyness)
  end
end
