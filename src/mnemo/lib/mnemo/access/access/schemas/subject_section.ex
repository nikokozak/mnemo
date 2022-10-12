defmodule Mnemo.Access.Schemas.SubjectSection do
  use Mnemo.Access.Schemas.Schema
  alias Mnemo.Access.Schemas.{Subject, ContentBlock, StudentProgression}

  @derive {Jason.Encoder,
           only: [
             :id,
             :title,
             :subject_id,
             :order_in_subject
           ]}

  schema "subject_sections" do
    belongs_to :subject, Subject, on_replace: :delete

    field(:title, :string)
    field(:order_in_subject, :integer, default: 0)

    has_many :content_blocks, ContentBlock

    many_to_many :student_progressions, StudentProgression,
      join_through: "student_progression_subject_section",
      on_replace: :delete

    timestamps()
  end
end
