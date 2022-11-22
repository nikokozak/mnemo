defmodule Test.Fixtures do
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  alias Mnemo.Access.Schemas.{
    Student,
    Subject,
    Section,
    Block,
    Enrollment,
    ScheduledBlock,
    ReviewBlock
  }

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

  def params(:enrollment, %{subject_id: _, student_id: _} = overrides) do
    fields =
      %{}
      |> Map.merge(overrides)

    %Enrollment{}
    |> Enrollment.create_changeset(fields)
  end

  def params(
        :scheduled_block,
        %{student_id: _, subject_id: _, block_id: _, review_at: _} = overrides
      ) do
    fields =
      %{}
      |> Map.merge(overrides)

    %ScheduledBlock{}
    |> ScheduledBlock.create_changeset(fields)
  end

  def params(:review_block, %{student_id: _, subject_id: _, block_id: _} = overrides) do
    fields =
      %{}
      |> Map.merge(overrides)

    %ReviewBlock{}
    |> ReviewBlock.create_changeset(fields)
  end
end
