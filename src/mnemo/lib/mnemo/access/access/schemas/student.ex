defmodule Mnemo.Access.Schemas.Student do
  use Ecto.Schema
  alias Mnemo.Access.Schemas.Subject

  @derive {Jason.Encoder, only: [:email]}
  @primary_key {:email, :string, autogenerate: false}

  schema "students" do
    has_many :subjects, Subject, foreign_key: :owner_id

    timestamps()
  end
end
