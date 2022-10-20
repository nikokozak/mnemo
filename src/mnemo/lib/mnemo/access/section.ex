defmodule Mnemo.Access.Schemas.Section do
  use Mnemo.Access.Schemas.Schema
  alias Ecto.Multi
  alias Mnemo.Access.Schemas.{Subject, Block, Enrollment}
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  @derive {Jason.Encoder,
           only: [
             :id,
             :title,
             :subject_id,
             :order_in_subject
           ]}

  schema "sections" do
    belongs_to :subject, Subject, on_replace: :delete

    field(:title, :string)
    field(:order_in_subject, :integer, default: 0)

    has_many :blocks, Block

    many_to_many :enrollments, Enrollment,
      join_through: "enrollment_section",
      on_replace: :delete

    timestamps()
  end

  ### ************ READ / QUERY FUNCTIONS *******************###

  def where_id(query \\ __MODULE__, section_id), do: from(s in query, where: s.id == ^section_id)

  def where_subject(query \\ __MODULE__, subject_id),
    do: from(s in query, where: s.subject_id == ^subject_id)

  def where_order(query \\ __MODULE__, order) when is_integer(order),
    do: from(s in query, where: s.order_in_subject == ^order)

  def ordered(query \\ __MODULE__), do: from(s in query, order_by: s.order_in_subject)

  def count(query \\ __MODULE__), do: from(s in query, select: count(s.id))

  def load_blocks(query = %Ecto.Query{}) do
    from(q in query,
      left_join: b in assoc(q, :blocks),
      order_by: b.order_in_section,
      preload: [blocks: b]
    )
  end

  def load_enrollments(query = %Ecto.Query{}),
    do: Ecto.Query.preload(query, :enrollments)

  def only_fields(query = %Ecto.Query{}, list_of_fields) when is_list(list_of_fields),
    do: Ecto.Query.select(query, ^list_of_fields)

  ### ************ CHANGESET / INSERT FUNCTIONS *******************###

  def create_changeset(block, %{subject_id: subject_id} = params) do
    block
    |> cast(params, ~w(title subject_id)a)
    |> put_change(:order_in_subject, current_order(subject_id))
    |> foreign_key_constraint(:subject_id)
  end

  defp current_order(subject_id),
    do: __MODULE__ |> where_subject(subject_id) |> count() |> PGRepo.one()

  def update_changeset(block, params) do
    block
    |> cast(params, ~w(title)a)
  end

  def update_order_changeset(section = %__MODULE__{}, new_order) do
    section
    |> cast(%{order_in_subject: new_order}, [:order_in_subject])
    # Update all other sections as well by using update_order_multi
    |> prepare_changes(fn changeset ->
      section_being_moved = changeset.data

      update_order_multi(section_being_moved, new_order)
      |> changeset.repo.transaction()

      changeset
    end)
  end

  def delete_changeset(section = %__MODULE__{}) do
    section
    |> cast(%{}, [])
    |> prepare_changes(fn changeset ->
      # use an absurd number, which will simply reorder sections starting at
      # section order, and until end of sections.
      update_order_multi(changeset.data, 1_000_000)
      |> changeset.repo.transaction()

      changeset
    end)
  end

  def update_order_multi(section, new_order) when is_binary(section) do
    __MODULE__
    |> where_id(section)
    |> PGRepo.one()
    |> update_order_multi(new_order)
  end

  def update_order_multi(section = %__MODULE__{}, new_order) do
    cond do
      section.order_in_subject == new_order ->
        do_nothing_multi(section)

      section.order_in_subject < new_order ->
        reorder_upwards_multi(section, new_order)

      section.order_in_subject > new_order ->
        reorder_downwards_multi(section, new_order)
    end
  end

  defp do_nothing_multi(section) do
    Multi.new()
    |> Multi.put({:reordered_section, section.id}, section)
  end

  defp reorder_upwards_multi(section, new_order) do
    sections_to_reorder =
      from(s in __MODULE__,
        where: s.order_in_subject > ^section.order_in_subject,
        where: s.order_in_subject <= ^new_order,
        where: s.subject_id == ^section.subject_id,
        order_by: s.order_in_subject
      )
      |> PGRepo.all()

    reorder_multi(sections_to_reorder, section.order_in_subject)
  end

  defp reorder_downwards_multi(section, new_order) do
    sections_to_reorder =
      from(s in __MODULE__,
        where: s.order_in_subject < ^section.order_in_subject,
        where: s.order_in_subject >= ^new_order,
        where: s.subject_id == ^section.subject_id,
        order_by: s.order_in_subject
      )
      |> PGRepo.all()

    reorder_multi(sections_to_reorder, new_order + 1)
  end

  # defp reorder_multi(sections_to_reorder, section_inserting, reduce_start_order, target_order) do
  defp reorder_multi(sections_to_reorder, reduce_start_order) do
    Enum.reduce(sections_to_reorder, {reduce_start_order, Multi.new()}, fn section,
                                                                           {order, multi} ->
      {order + 1,
       Multi.update(
         multi,
         # the Multi's name
         {:updated_section, section.id},
         cast(section, %{order_in_subject: order}, [:order_in_subject])
       )}
    end)
    # We don't care about the order val anymore ({order, Multi})
    |> elem(1)

    # Now we update section_inserting
    #   |> Multi.update(
    #     {:reordered_section, section_inserting.id},
    #     cast(section_inserting, %{order_in_subject: target_order}, [:order_in_subject])
    #   )
  end
end
