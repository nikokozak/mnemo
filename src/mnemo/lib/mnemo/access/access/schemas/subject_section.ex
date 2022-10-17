defmodule Mnemo.Access.Schemas.SubjectSection do
  use Mnemo.Access.Schemas.Schema
  alias Mnemo.Access.Schemas.{Subject, ContentBlock, StudentProgression}

  @derive {Jason.Encoder,
           only: [
             :id,
             :title,
             :subject_id,
             :order_in_subject
           ]}

  schema "subject_sections" do
    belongs_to :subject, Subject, on_replace: :delete

    field(:title, :string)
    field(:order_in_subject, :integer, default: 0)

    has_many :content_blocks, ContentBlock

    many_to_many :student_progressions, StudentProgression,
      join_through: "student_progression_subject_section",
      on_replace: :delete

    timestamps()
  end

  ### ************ READ / QUERY FUNCTIONS *******************###

  def with_id(query \\ __MODULE__, section_id), do: from(s in query, where: s.id == ^section_id)

  def with_subject(query \\ __MODULE__, subject_id),
    do: from(s in query, where: s.subject_id == ^subject_id)

  def with_order(query \\ __MODULE__, order) when is_integer(order),
    do: from(s in query, where: s.order_in_subject == ^order)

  def load_content_blocks(query = %Ecto.Query{}),
    do: Ecto.Query.preload(query, sections: :content_blocks)

  def load_student_progressions(query = %Ecto.Query{}),
    do: Ecto.Query.preload(query, :student_progressions)

  def only_fields(query = %Ecto.Query{}, list_of_fields) when is_list(list_of_fields),
    do: Ecto.Query.select(query, ^list_of_fields)

  ### ************ CHANGESET / INSERT FUNCTIONS *******************###

  def create_changeset(item, params \\ %{}) do
    item
    |> cast(params, ~w(title subject_id order_in_subject)a)
  end

  def update_changeset(item, params) do
    item
    |> cast(params, ~w(title order_in_subject)a)
  end

  def delete_changeset(item) do
    item
    |> change(item)
  end
end
