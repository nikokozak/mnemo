defmodule Mnemo.Access.Schemas.ReviewBlock do
  use Mnemo.Access.Schemas.Schema
  alias Mnemo.Access.Schemas.{Subject, Student, Block}

  @derive {Jason.Encoder,
           only: [
             :id,
             :student_id,
             :subject_id,
             :block_id
           ]}

  schema "student_review_queue" do
    belongs_to :student, Student, on_replace: :delete
    belongs_to :subject, Subject, on_replace: :delete
    belongs_to :block, Block, on_replace: :delete
  end

  def where_id(query \\ __MODULE__, block_id), do: from(cb in query, where: cb.id == ^block_id)

  def where_student(query \\ __MODULE__, student_id),
    do: from(cb in query, where: cb.student_id == ^student_id)

  def where_subject(query \\ __MODULE__, subject_id),
    do: from(cb in query, where: cb.subject_id == ^subject_id)

  def where_block(query \\ __MODULE__, block_id),
    do: from(cb in query, where: cb.block_id == ^block_id)

  def limit(query \\ __MODULE__, num \\ 1),
    do: from(cb in query, limit: ^num)

  @spec create_changeset(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          %{
            :block_id => any,
            :review_at => any,
            :student_id => any,
            :subject_id => any,
            optional(:__struct__) => none,
            optional(atom | binary) => any
          }
        ) :: Ecto.Changeset.t()
  def create_changeset(
        scheduled_block,
        %{
          student_id: _student_id,
          subject_id: _subject_id,
          block_id: _block_id,
          review_at: _review_at
        } = params
      ) do
    scheduled_block
    |> cast(params, ~w(
        student_id
        subject_id
        review_at
        block_id)a)
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:subject_id)
    |> foreign_key_constraint(:block_id)
  end

  def delete_changeset(scheduled_block) do
    # TODO: redundant?
    scheduled_block
    |> cast(%{}, [])
  end
end
