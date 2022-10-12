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
      # See ContentBlock Schema for info on defaults, types in maps.
      add(:type, :string)
      add(:testable, :boolean)
      add(:order_in_section, :integer)
      add(:media, :map)

      # Static Content Blocks
      add(:static_content, {:array, :map})

      # Single Answer Question
      add(:saq_question_img, :string)
      add(:saq_question_text, :string)
      add(:saq_answer_choices, {:array, :map})

      # Multiple Choice Question
      add(:mcq_question_img, :string)
      add(:mcq_question_text, :string)
      add(:mcq_answer_choices, {:array, :map})
      add(:mcq_answer_correct, :string)

      # Fill in the Blank Question
      add(:fibq_question_img, :string)
      add(:fibq_question_text_template, :string)

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

    create table(:student_progressions) do
      add(:owner_id, references(:students, column: :email, type: :string, on_delete: :delete_all))
      add(:subject_id, references(:subjects, on_delete: :delete_all))
      add(:enrollment_pending, :boolean)
      add(:subject_section_cursor_id, references(:subject_sections))
      add(:content_block_cursor_id, references(:content_blocks))

      timestamps()
    end

    create(index(:student_progressions, [:owner_id]))
    create(index(:student_progressions, [:subject_id]))

    create(
      unique_index(
        :student_progressions,
        [:owner_id, :subject_id],
        name: :owner_id_subject_id_unique_index
      )
    )

    # Many-to-Many Student Progressions <-> Subject Sections
    create table(:student_progression_subject_section, primary_key: false) do
      add(
        :student_progression_id,
        references(:student_progressions, on_delete: :delete_all),
        primary_key: true
      )

      add(
        :subject_section_id,
        references(:subject_sections, on_delete: :delete_all),
        primary_key: true
      )
    end

    create(index(:student_progression_subject_section, [:student_progression_id]))
    create(index(:student_progression_subject_section, [:subject_section_id]))

    create(
      unique_index(
        :student_progression_subject_section,
        [:student_progression_id, :subject_section_id],
        name: :student_progression_id_subject_section_id_unique_index
      )
    )

    # Many-to-Many Student Progressions <-> Content Blocks
    create table(:student_progression_content_block, primary_key: false) do
      add(
        :student_progression_id,
        references(:student_progressions, on_delete: :delete_all),
        primary_key: true
      )

      add(
        :content_block_id,
        references(:content_blocks, on_delete: :delete_all),
        primary_key: true
      )
    end

    create(index(:student_progression_content_block, [:student_progression_id]))
    create(index(:student_progression_content_block, [:content_block_id]))

    create(
      unique_index(
        :student_progression_content_block,
        [:student_progression_id, :content_block_id],
        name: :student_progression_id_content_block_id_unique_index
      )
    )

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
