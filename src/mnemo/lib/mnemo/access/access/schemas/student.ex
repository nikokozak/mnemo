defmodule Mnemo.Access.Schemas.Student do
  use Mnemo.Access.Schemas.Schema

  @derive {Jason.Encoder, only: [:email]}

  schema "students" do
    field(:email, :string)

    timestamps()
  end
end
