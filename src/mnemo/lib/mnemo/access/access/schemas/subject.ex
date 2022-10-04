defmodule Mnemo.Access.Schemas.Subject do
  use Mnemo.Access.Schemas.Schema
  alias Mnemo.Access.Schemas.Student

  @derive {Jason.Encoder,
           only: [
             :id,
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

    timestamps()
  end
end
