defmodule Mnemo.Access.Schemas.Subject do
  use Mnemo.Access.Schemas.Schema
  alias Mnemo.Access.Schemas.{Student, SubjectSection, ContentBlock}

  @derive {Jason.Encoder,
           only: [
             :id,
             :owner_id,
             :title,
             :description,
             :published,
             :private,
             :institution_only,
             :price
           ]}

  schema "subjects" do
    belongs_to :owner, Student, on_replace: :delete, type: :string

    field(:title, :string, default: "Name of the new subject")
    field(:description, :string)
    field(:published, :boolean, default: false)
    field(:private, :boolean, default: true)
    field(:institution_only, :boolean, default: false)
    field(:price, :integer, default: 0)

    has_many :sections, SubjectSection
    has_many :content_blocks, ContentBlock

    timestamps()
  end

  ### ************ READ / QUERY FUNCTIONS *******************###

  def with_id(query \\ __MODULE__, subject_id), do: from(s in query, where: s.id == ^subject_id)

  def load_sections(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :sections)

  def load_content_blocks(query = %Ecto.Query{}),
    do: Ecto.Query.preload(query, :content_blocks)

  def only_fields(query = %Ecto.Query{}, list_of_fields) when is_list(list_of_fields),
    do: Ecto.Query.select(query, ^list_of_fields)

  ### ************ CHANGESET / INSERT FUNCTIONS *******************###

  def create_changeset(item, params \\ %{}) do
    item
    |> cast(params, ~w(title description published private institution_only price)a)
  end

  def update_changeset(item, params) do
    item
    |> create_changeset(params)
  end

  def delete_changeset(item) do
    item
    |> change(item)
  end
end
