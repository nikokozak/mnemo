defmodule Mnemo.Access.Schemas.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      require Ecto.Query
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      import Ecto.Changeset
      import Ecto.Query, only: [from: 2]
    end
  end
end
