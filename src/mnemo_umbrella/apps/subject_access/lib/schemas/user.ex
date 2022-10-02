defmodule SubjectAccess.Schemas.Student do
  use SubjectAccess.Schemas.Schema

  @derive {Jason.Encoder, only: [:email]}

  schema "students" do
    field(:email, :string)

    timestamps()
  end
end
