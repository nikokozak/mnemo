defmodule Test.Fixtures do
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.{Student, Subject, Section, Block, Enrollment}

  def create(type, overrides \\ %{}) do
    params = params(type, overrides)
    PGRepo.insert(params)
  end

  def params(_, overrides \\ %{})

  def params(:student, overrides) do
    fields =
      %{
        email: Faker.Internet.email()
      }
      |> Map.merge(overrides)

    %Student{}
    |> Student.create_changeset(fields)
  end

  def params(:subject, %{student_id: _student_id} = overrides) do
    fields =
      %{
        title: Faker.Lorem.sentence(),
        description: Faker.Lorem.Shakespeare.hamlet()
      }
      |> Map.merge(overrides)

    %Subject{}
    |> Subject.create_changeset(fields)
  end

  def params(:section, %{subject_id: _s} = overrides) do
    fields =
      %{
        title: Faker.Lorem.sentence()
      }
      |> Map.merge(overrides)

    %Section{}
    |> Section.create_changeset(fields)
  end

  def params(:block, %{subject_id: _, section_id: _} = overrides) do
    fields =
      %{
        type: "static"
      }
      |> Map.merge(overrides)

    %Block{}
    |> Block.create_changeset(fields)
  end

  def params(:enrollment, overrides) do
    fields =
      %{}
      |> Map.merge(overrides)

    %Enrollment{}
    |> Enrollment.create_changeset(fields)
  end
end
