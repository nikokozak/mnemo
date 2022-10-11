defmodule Test.Fixtures do
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo
  alias Mnemo.Access.Schemas.{Student, Subject, SubjectSection, ContentBlock}

  def create!(type, overrides \\ %{}) do
    params = params(type, overrides)
    PGRepo.insert!(params)
  end

  def params(_, overrides \\ %{})

  def params(:student, overrides) do
    fields =
      %{
        email: Faker.Internet.email()
      }
      |> Map.merge(overrides)

    struct(Student, fields)
  end

  def params(:subject, overrides) do
    fields =
      %{
        title: Faker.Lorem.sentence(),
        description: Faker.Lorem.Shakespeare.hamlet()
      }
      |> Map.merge(overrides)

    struct(Subject, fields)
  end

  def params(:subject_section, overrides) do
    fields =
      %{
        title: Faker.Lorem.sentence()
      }
      |> Map.merge(overrides)

    struct(SubjectSection, fields)
  end

  def params(:content_block, overrides) do
    fields =
      %{}
      |> Map.merge(overrides)

    struct(ContentBlock, fields)
  end
end
