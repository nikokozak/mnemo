defmodule Mnemo.Access.Schemas.SubjectSection do
  use Mnemo.Access.Schemas.Schema
  alias Mnemo.Access.Schemas.{Subject, ContentBlock}

  @derive {Jason.Encoder,
           only: [
             :id,
             :title,
             :subject_id
           ]}

  schema "subject_sections" do
    belongs_to :subject, Subject, on_replace: :delete
    has_many :content_blocks, ContentBlock
    field(:title, :string)

    timestamps()
  end
end
