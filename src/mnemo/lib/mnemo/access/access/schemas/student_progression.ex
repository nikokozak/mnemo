defmodule Mnemo.Access.Schemas.StudentProgression do
  use Mnemo.Access.Schemas.Schema
  alias Mnemo.Access.Schemas.{Student, Subject, ContentBlock, SubjectSection}

  @derive {Jason.Encoder,
           only: [
             :id,
             :owner,
             :subject,
             :enrollment_pending,
             :subject_section_cursor,
             :content_block_cursor,
             :completed_blocks,
             :completed_sections
           ]}

  # TODO:
  # - what happens when, during editing, one of the sections or content blocks is deleted? -> invoke update.
  # - what happens when they're edited? -> initially, nothing.

  schema "student_progressions" do
    belongs_to :owner, Student, on_replace: :delete, type: :string
    belongs_to :subject, Subject, on_replace: :delete

    field :enrollment_pending, :boolean, default: false

    belongs_to :subject_section_cursor, SubjectSection, on_replace: :nilify
    belongs_to :content_block_cursor, ContentBlock, on_replace: :nilify

    many_to_many :completed_sections, SubjectSection,
      join_through: "student_progression_subject_section",
      on_replace: :delete

    many_to_many :completed_blocks, ContentBlock,
      join_through: "student_progression_content_block",
      on_replace: :delete

    timestamps()
  end
end
