defmodule Mnemo.Access.Schemas.Subject do
  use Mnemo.Access.Schemas.Schema
  alias Mnemo.Access.Schemas.{Student, Section, Block}

  schema "subjects" do
    belongs_to :student, Student, on_replace: :delete

    field(:title, :string, default: "Name of the new subject")
    field(:description, :string)
    field(:published, :boolean, default: false)
    field(:private, :boolean, default: true)
    field(:institution_only, :boolean, default: false)
    field(:price, :integer, default: 0)

    has_many :sections, Section
    has_many :blocks, Block

    timestamps()
  end

  ### ************ READ / QUERY FUNCTIONS *******************###

  def where_id(query \\ __MODULE__, subject_id),
    do: from(s in query, where: s.id == ^subject_id)

  def where_student(query \\ __MODULE__, student_id),
    do: from(s in query, where: s.student_id == ^student_id)

  def load_sections(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :sections)

  def load_sections_with_blocks(query = %Ecto.Query{}) do
    from(q in query,
      left_join: s in assoc(q, :sections),
      order_by: s.order_in_subject,
      left_join: b in assoc(s, :blocks),
      order_by: b.order_in_section,
      preload: [sections: {s, blocks: b}]
    )
  end

  def load_blocks(query = %Ecto.Query{}),
    do: Ecto.Query.preload(query, :blocks)

  def only_fields(query = %Ecto.Query{}, list_of_fields) when is_list(list_of_fields),
    do: Ecto.Query.select(query, ^list_of_fields)

  ### ************ CHANGESET / INSERT FUNCTIONS *******************###

  def create_changeset(item, params \\ %{}) do
    item
    |> cast(params, ~w(title student_id description published private institution_only price)a)
    |> foreign_key_constraint(:student_id)
  end

  def update_changeset(item, params) do
    item
    |> create_changeset(params)
  end

  def delete_changeset(subject) do
    subject
    |> change()
  end
end
