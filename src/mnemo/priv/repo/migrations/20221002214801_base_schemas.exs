defmodule Mnemo.Resources.Postgres.Repo.Migrations.BaseSchemas do
  use Ecto.Migration

  def change do
    create table(:students) do
      add(:email, :string, null: false)

      timestamps()
    end

    create(index(:students, [:email]))

    create(
      unique_index(
        :students,
        :email,
        name: :student_email_unique_index
      )
    )

    create table(:subjects) do
      add(:student_id, references(:students, on_delete: :delete_all, null: false))
      add(:title, :string)
      add(:description, :string)
      add(:image_url, :string)
      add(:published, :boolean)
      add(:private, :boolean)
      add(:institution_only, :boolean)
      add(:price, :integer)

      timestamps()
    end

    create table(:sections) do
      add(:title, :string)
      add(:order_in_subject, :integer)

      timestamps()
    end

    create table(:blocks) do
      # See Block Schema for info on defaults, types in maps.
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
      add(:fibq_question_structure, {:array, :map})

      # FlashCard
      add(:fc_front_content, {:array, :map})
      add(:fc_back_content, {:array, :map})

      timestamps()
    end

    alter table(:sections) do
      add(:subject_id, references(:subjects, on_delete: :delete_all))
    end

    alter table(:blocks) do
      # This might not be necessary, we're accessing them through sections.
      add(:subject_id, references(:subjects, on_delete: :delete_all))
      add(:section_id, references(:sections, on_delete: :delete_all))
    end

    create table(:enrollments) do
      add(:student_id, references(:students, on_delete: :delete_all))
      add(:subject_id, references(:subjects, on_delete: :delete_all))
      add(:pending, :boolean)
      add(:completed, :boolean)
      add(:percent_complete, :integer)
      add(:block_cursor_id, references(:blocks, on_delete: :nilify_all))

      add(:num_reviewed_today, :integer)
      add(:last_reviewed_at, :date)
      timestamps()
    end

    create(index(:enrollments, [:student_id]))
    create(index(:enrollments, [:subject_id]))

    create(
      unique_index(
        :enrollments,
        [:student_id, :subject_id],
        name: :student_id_subject_id_unique_index
      )
    )

    # Many-to-Many Enrollment <-> Subject Sections
    create table(:enrollment_section, primary_key: false) do
      add(
        :enrollment_id,
        references(:enrollments, on_delete: :delete_all),
        primary_key: true
      )

      add(
        :section_id,
        references(:sections, on_delete: :delete_all),
        primary_key: true
      )
    end

    create(index(:enrollment_section, [:enrollment_id]))
    create(index(:enrollment_section, [:section_id]))

    create(
      unique_index(
        :enrollment_section,
        [:enrollment_id, :section_id],
        name: :enrollment_id_section_id_unique_index
      )
    )

    # Many-to-Many Enrollment <-> Content Blocks
    create table(:enrollment_block, primary_key: false) do
      add(
        :enrollment_id,
        references(:enrollments, on_delete: :delete_all),
        primary_key: true
      )

      add(
        :block_id,
        references(:blocks, on_delete: :delete_all),
        primary_key: true
      )
    end

    create(index(:enrollment_block, [:enrollment_id]))
    create(index(:enrollment_block, [:block_id]))

    create(
      unique_index(
        :enrollment_block,
        [:enrollment_id, :block_id],
        name: :enrollment_id_block_id_unique_index
      )
    )

    create table(:scheduled_blocks) do
      add(:student_id, references(:students, on_delete: :delete_all))
      add(:subject_id, references(:subjects, on_delete: :delete_all))
      add(:block_id, references(:blocks, on_delete: :delete_all))
      add(:review_at, :date)
    end

    create(
      unique_index(
        :scheduled_blocks,
        [:student_id, :block_id],
        name: :student_id_block_id_unique_index
      )
    )

    create table(:student_review_queue) do
      add(:student_id, references(:students, on_delete: :delete_all))
      add(:subject_id, references(:subjects, on_delete: :delete_all))
      add(:block_id, references(:blocks, on_delete: :delete_all))
    end

    create(
      unique_index(
        :student_review_queue,
        [:student_id, :subject_id, :block_id],
        name: :student_id_subject_id_block_id_unique_index
      )
    )

    create table(:student_completed_reviews) do
      add(:student_id, references(:students, on_delete: :delete_all))
      add(:subject_id, references(:subjects, on_delete: :delete_all))
      add(:block_id, references(:blocks, on_delete: :delete_all))
      add(:succeeded, :boolean)
      add(:answers, {:array, :string})
      add(:correct_in_a_row, :integer)
      add(:interval_to_next_review, :integer)
      add(:easyness, :decimal)
      add(:time_taken, :integer)
      add(:date_suggested, :date)
      add(:datetime_completed, :utc_datetime)
    end
  end
end
