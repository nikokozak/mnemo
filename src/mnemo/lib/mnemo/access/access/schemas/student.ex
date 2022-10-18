defmodule Mnemo.Access.Schemas.Student do
  use Mnemo.Access.Schemas.Schema
  alias Mnemo.Access.Schemas.{Subject, Enrollment}

  @derive {Jason.Encoder, only: [:email]}

  schema "students" do
    field :email, :string

    has_many :subjects, Subject
    has_many :enrollments, Enrollment

    timestamps()
  end

  ### ************ READ / QUERY FUNCTIONS *******************###

  def where_id(query \\ __MODULE__, student_id),
    do: from(student in query, where: student.id == ^student_id)

  def where_email(query \\ __MODULE__, student_email),
    do: from(student in query, where: student.email == ^student_email)

  def load_enrollments(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :enrollments)

  def load_subjects(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :subjects)

  ### ************ CHANGESET / INSERT FUNCTIONS *******************###

  def create_changeset(item, params \\ %{}) do
    item
    |> cast(params, ~w(email)a)
  end

  def update_changeset(item, params) do
    item
    |> create_changeset(params)
  end

  def delete_changeset(item) do
    item
    |> change()
  end
end
