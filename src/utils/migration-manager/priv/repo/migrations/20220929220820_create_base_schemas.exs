defmodule Mnemo.Repo.Migrations.CreateBaseSchemas do
  use Ecto.Migration

  def change do
    create table(:students) do
      add(:email, :string)
    end

    create table(:subjects) do
      add(:owner, references(:students))
      add(:title, :string)
      add(:description, :string)
      add(:published, :boolean)
      add(:private, :boolean)
      add(:institution_only, :boolean)
      add(:price, :integer)

      add(:sections, references(:subject_sections))

      timestamps
    end

    create table(:subject_sections) do
      add(:title, :string)
      add(:content_blocks, references(:content_blocks))
    end

    create table(:content_blocks) do
      add(:subject_id, refences(:subjects))
      add(:section_id, references(:subject_sections))
      add(:testable, :boolean)
      add(:order_in_section, :integer)
      add(:type, :string)
      add(:media, :map)
      add(:block, :map)
    end

    create table(:student_progression) do
      add(:student_id, references(:students))
      add(:subject_id, references(:subjects))
      add(:enrollment_pending, :boolean)
      add(:completed_blocks, references(:content_blocks))
      add(:completed_sections, references(:subject_sections))
      add(:content_block_cursor, references(:content_blocks))
      add(:subject_section_cursor, references(:subject_section))
    end

    create table(:scheduled_content_blocks) do
      add(:student_id, references(:students))
      add(:subject_id, references(:subjects))
      add(:block_id, refernces(:content_blocks))
      add(:review_at, :date)
    end

    create table(:student_review_queue) do
      add(:student_id, references(:students))
      add(:subject_id, references(:subjects))
      add(:content_block_id, references(:content_blocks))
    end

    create table(:student_completed_reviews) do
      add(:student_id, references(:students))
      add(:subject_id, references(:subjects))
      add(:content_block_id, references(:content_blocks))
      add(:succeeded, :boolean)
      add(:answers, {:array, :string})
      add(:attempts, :integer)
      add(:time_taken, :integer)
      add(:date_suggested, :date)
      add(:date_reviewed, :date)
    end
  end
end
