defmodule Mnemo.Resources.Postgres.Repo.Migrations.BaseSchemas do
  use Ecto.Migration

  def change do
    create table(:students, primary_key: false) do
      add(:email, :string, primary_key: true)

      timestamps()
    end

    create table(:subjects) do
      add(:owner_id, references(:students, column: :email, type: :string, on_delete: :delete_all))
      add(:title, :string)
      add(:description, :string)
      add(:published, :boolean)
      add(:private, :boolean)
      add(:institution_only, :boolean)
      add(:price, :integer)

      timestamps()
    end

    create table(:subject_sections) do
      add(:title, :string)

      timestamps()
    end

    create table(:content_blocks) do
      add(:type, :string)
      add(:testable, :boolean)
      add(:order_in_section, :integer)
      add(:media, :map)

      # Static Content Blocks
      add(:static_content, {:array, :map})

      # Single Answer Question
      add(:saq_question_img, :string)
      add(:saq_question_text, :string)
      add(:saq_answer_correct, {:array, :string})

      # Multiple Choice Question
      add(:mcq_question_img, :string)
      add(:mcq_question_text, :string)
      add(:mcq_answer_choices, {:array, :map})
      add(:mcq_answer_correct, :string)

      # Fill in the Blank Question
      add(:fibq_question_img, :string)
      add(:fibq_template_text, :string)

      # FlashCard
      add(:fc_front_content, {:array, :map})
      add(:fc_back_content, {:array, :map})

      timestamps()
    end

    alter table(:subject_sections) do
      add(:subject_id, references(:subjects, on_delete: :delete_all))
      # add(:content_blocks, references(:content_blocks))
    end

    alter table(:content_blocks) do
      # This might not be necessary, we're accessing them through sections.
      # add(:subject_id, references(:subjects))
      add(:subject_section_id, references(:subject_sections, on_delete: :delete_all))
    end

    create table(:student_progression) do
      add(:owner_id, references(:students, column: :email, type: :string, on_delete: :delete_all))
      add(:subject_id, references(:subjects))
      add(:enrollment_pending, :boolean)
      add(:completed_sections, references(:subject_sections))
      add(:subject_section_cursor, references(:subject_sections))
      add(:completed_blocks, references(:content_blocks))
      add(:content_block_cursor, references(:content_blocks))
    end

    create table(:scheduled_content_blocks) do
      add(:owner_id, references(:students, column: :email, type: :string, on_delete: :delete_all))
      add(:subject_id, references(:subjects))
      add(:block_id, references(:content_blocks))
      add(:review_at, :date)
    end

    create table(:student_review_queue) do
      add(:owner_id, references(:students, column: :email, type: :string, on_delete: :delete_all))
      add(:subject_id, references(:subjects, on_delete: :delete_all))
      add(:content_block_id, references(:content_blocks, on_delete: :delete_all))
    end

    create table(:student_completed_reviews) do
      add(:owner_id, references(:students, column: :email, type: :string, on_delete: :delete_all))
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
