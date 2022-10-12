defmodule Mnemo.Access.Schemas.ContentBlock do
  use Mnemo.Access.Schemas.Schema
  alias Mnemo.Access.Schemas.{SubjectSection, StudentProgression}

  @derive {Jason.Encoder,
           only: [
             :subject_section_id,
             :id,
             :type,
             :testable,
             :order_in_section,
             :media,
             :static_content,
             :saq_question_img,
             :saq_question_text,
             :saq_answer_choices,
             :mcq_question_img,
             :mcq_question_text,
             :mcq_answer_choices,
             :mcq_answer_correct,
             :fibq_question_img,
             :fibq_question_text_template,
             :fc_front_content,
             :fc_back_content
           ]}

  schema "content_blocks" do
    belongs_to :subject_section, SubjectSection, on_replace: :delete

    field :type, :string, default: "static"
    field :testable, :boolean, default: false
    field :order_in_section, :integer, default: 0
    field :media, :map

    # This should be an array of maps of 
    # %{ type: "text" | "img", content: :string }
    field :static_content, {:array, :map}, default: []

    # This should be an array of maps of 
    # %{ type: "text" | "img", content: :string }
    field :fc_front_content, {:array, :map}, default: []
    field :fc_back_content, {:array, :map}, default: []

    field :saq_question_img, :string
    field :saq_question_text, :string
    # This allows for multiple correct answers to the same question.
    # %{ text: :string }
    field :saq_answer_choices, {:array, :map},
      default: [
        %{"text" => nil}
      ]

    field :mcq_question_img, :string
    field(:mcq_question_text, :string)
    # This should be a map of {"a" => "an answer"}
    field :mcq_answer_choices, {:array, :map},
      default: [
        %{"key" => "a", "text" => "A first answer"},
        %{"key" => "b", "text" => "A second answer"}
      ]

    # This should be a key of the above map, i.e. "a"
    field :mcq_answer_correct, :string, default: "a"

    field :fibq_question_img, :string
    # This is "raw" text, i.e. "the color of the sky is {{ blue }}"
    field :fibq_question_text_template, :string

    many_to_many :student_progressions, StudentProgression,
      join_through: "student_progression_content_block",
      on_replace: :delete

    timestamps()
  end
end
