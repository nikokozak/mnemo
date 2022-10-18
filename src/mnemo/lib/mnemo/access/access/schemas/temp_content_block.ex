defmodule Mnemo.Access.Schemas.ContentBlock do
  use Mnemo.Access.Schemas.Schema
  alias Ecto.Multi
  alias Mnemo.Access.Schemas.{Subject, Section, Enrollment}

  @derive {Jason.Encoder,
           only: [
             :id,
             :section_id,
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
    belongs_to :section, Section, on_replace: :delete
    belongs_to :subject, Subject, on_replace: :delete

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

    many_to_many :enrollments, Enrollment,
      join_through: "enrollment_block",
      on_replace: :delete

    timestamps()
  end

  ### ************ READ / QUERY FUNCTIONS *******************###

  def where_id(query \\ __MODULE__, block_id), do: from(cb in query, where: cb.id == ^block_id)

  def where_type(query \\ __MODULE__, type), do: from(cb in query, where: cb.type == ^type)

  def where_testable(query \\ __MODULE__, testable?) when is_boolean(testable?),
    do: from(cb in query, where: cb.testable == ^testable?)

  def where_subject(query \\ __MODULE__, subject_id),
    do: from(cb in query, where: cb.subject_id == ^subject_id)

  def where_section(query \\ __MODULE__, section_id),
    do: from(cb in query, where: cb.section_id == ^section_id)

  def where_order(query \\ __MODULE__, order) when is_integer(order),
    do: from(cb in query, where: cb.order_in_section == ^order)

  def ordered(query \\ __MODULE__, asc_or_desc \\ :asc)

  def ordered(query, :asc),
    do: from(cb in query, order_by: [asc: cb.order_in_section])

  def ordered(query, :desc),
    do: from(cb in query, order_by: [desc: cb.order_in_section])

  def count(query \\ __MODULE__), do: from(cb in query, select: count(cb.id))

  def load_enrollments(query = %Ecto.Query{}),
    do: Ecto.Query.preload(query, :enrollments)

  def only_fields(query = %Ecto.Query{}, list_of_fields) when is_list(list_of_fields),
    do: Ecto.Query.select(query, ^list_of_fields)

  ### ************ UTILITY / HELPER FUNCTIONS *******************###

  # Returns next block in current section, or first block in next section, or nil if none
  def next_block(block = %__MODULE__{}) do
    next_block_in_current_section =
      __MODULE__
      |> where_section(block.section_id)
      |> where_order(block.order_in_section + 1)
      |> PGRepo.one()

    case next_block_in_current_section do
      nil ->
        current_section =
          Section
          |> where_id(block.section_id)
          |> Repo.one()

        next_section =
          Section
          |> Section.where_subject(current_section.subject_id)
          |> Section.where_order(current_section.order_in_subject + 1)
          |> Repo.one()

        case next_section do
          nil ->
            nil

          section ->
            __MODULE__
            |> where_section(section.id)
            |> ordered()
            |> Repo.one()
        end

      block ->
        block
    end
  end

  ### ************ CHANGESET / INSERT FUNCTIONS *******************###

  def create_changeset(item, %{section_id: section_id} = params) do
    item
    |> cast(params, ~w(
      subject_id
      section_id
      type 
      testable 
      media 
      static_content
      saq_question_img saq_question_text saq_answer_choices
      mcq_question_img mcq_question_text mcq_answer_choices mcq_answer_correct
      fibq_question_img fibq_question_text_template
      fc_front_content fc_back_content)a)
    |> put_change(:order_in_section, current_order(section_id))
  end

  defp current_order(section_id),
    do: __MODULE__ |> where_section(section_id) |> count() |> PGRepo.one()

  def with_subject(item, %Subject{} = subject) do
    item
    |> cast(%{subject_id: subject.id}, [:subject_id])
  end

  def with_section(item, %Section{} = section) do
    item
    |> cast(%{section_id: section.id}, [:section_id])
  end

  def update_changeset(item, params) do
    item
    |> cast(params, ~w(
      section_id
      type 
      testable 
      order_in_section 
      media 
      static_content
      saq_question_img saq_question_text saq_answer_choices
      mcq_question_img mcq_question_text mcq_answer_choices mcq_answer_correct
      fibq_question_img fibq_question_text_template
      fc_front_content fc_back_content)a)
  end

  def delete_changeset(item) do
    item
    |> change()
  end

  def update_order_multi(block, new_order, new_section_id \\ nil)

  def update_order_multi(block, new_order, nil) when is_binary(block) do
    __MODULE__
    |> where_id(block)
    |> PGRepo.one()
    |> update_order_multi(new_order)
  end

  def update_order_multi(block = %__MODULE__{}, new_order, nil) do
    cond do
      block.order_in_section == new_order ->
        do_nothing_multi(block)

      block.order_in_section < new_order ->
        reorder_upwards_multi(block, new_order)

      block.order_in_section > new_order ->
        reorder_downwards_multi(block, new_order)
    end
  end

  def update_order_multi(block, new_order, new_section_id) when is_binary(block) do
    __MODULE__
    |> where_id(block)
    |> PGRepo.one()
    |> update_order_multi(new_order, new_section_id)
  end

  def update_order_multi(block = %__MODULE__{}, new_order, new_section_id) do
    blocks_to_reorder_old_section =
      from(b in __MODULE__,
        where: b.order_in_section > ^block.order_in_section,
        where: b.section_id == ^block.section_id,
        order_by: b.order_in_section
      )
      |> PGRepo.all()

    blocks_to_reorder_new_section =
      from(b in __MODULE__,
        where: b.order_in_section >= ^block.order_in_section,
        where: b.section_id == ^new_section_id,
        order_by: b.order_in_section
      )
      |> PGRepo.all()

    reorder_multi(blocks_to_reorder_new_section, block, new_order + 1, new_order)
    |> reset_multi(blocks_to_reorder_old_section, block)
    |> Multi.update(
      {:new_section_block, block.id},
      cast(block, %{section_id: new_section_id}, [:section_id])
    )
  end

  defp do_nothing_multi(block), do: Multi.new() |> Multi.put({:reordered_block, block.id}, block)

  defp reorder_upwards_multi(block, new_order) do
    blocks_to_reorder =
      from(b in __MODULE__,
        where: b.order_in_section > ^block.order_in_section,
        where: b.order_in_section <= ^new_order,
        where: b.section_id == ^block.section_id,
        order_by: b.order_in_section
      )
      |> PGRepo.all()

    reorder_multi(blocks_to_reorder, block, block.order_in_section, new_order)
  end

  defp reorder_downwards_multi(block, new_order) do
    blocks_to_reorder =
      from(b in __MODULE__,
        where: b.order_in_section < ^block.order_in_section,
        where: b.order_in_section >= ^new_order,
        where: b.section_id == ^block.section_id,
        order_by: b.order_in_section
      )
      |> PGRepo.all()

    reorder_multi(blocks_to_reorder, block, new_order + 1, new_order)
  end

  defp reorder_multi(
         multi = %Multi{} \\ Multi.new(),
         blocks_to_reorder,
         block_inserting,
         reduce_start_order,
         target_order
       ) do
    Enum.reduce(blocks_to_reorder, {reduce_start_order, multi}, fn block, {order, multi} ->
      {order + 1,
       Multi.update(
         multi,
         # the Multi name
         {:updated_block, block.id},
         cast(block, %{order_in_section: order}, [:order_in_section])
       )}
    end)
    # We don't care about the order val anymore ({order, Multi})
    |> elem(1)
    # Now we update block_inserting
    |> Multi.update(
      {:reordered_block, block_inserting.id},
      cast(block_inserting, %{order_in_section: target_order}, [:order_in_section])
    )
  end

  # This just re-numbers blocks in a section where a certain block is being removed from the order.
  defp reset_multi(multi = %Multi{}, blocks_to_reorder, block_removing) do
    Enum.reduce(blocks_to_reorder, {block_removing.order_in_section, multi}, fn block,
                                                                                {order, multi} ->
      {order + 1,
       Multi.update(
         multi,
         {:reset_block, block.id},
         Ecto.Changeset.cast(block, %{order_in_section: order}, [:order_in_section])
       )}
    end)
    |> elem(1)
  end
end
