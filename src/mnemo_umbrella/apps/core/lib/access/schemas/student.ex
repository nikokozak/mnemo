defmodule Core.Access.Schemas.Student do
  use Core.Access.Schemas.Schema

  @derive {Jason.Encoder, only: [:email]}

  schema "students" do
    field(:email, :string)

    timestamps()
  end
end
