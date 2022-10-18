defmodule Mnemo.Access.Schemas.Enrollment do
  use Mnemo.Access.Schemas.Schema
  alias Mnemo.Access.Schemas.{Student, Subject, Block, Section}

  @derive {Jason.Encoder,
   only: [
     :id,
     :student_id,
     :subject_id,
     :pending,
     :block_cursor_id,
     :completed
     # :completed_blocks,
     # :completed_sections
   ]}

  schema "enrollments" do
    belongs_to :student, Student, on_replace: :delete
    belongs_to :subject, Subject, on_replace: :delete

    field :pending, :boolean, default: false
    field :completed, :boolean, default: false

    belongs_to :block_cursor, Block, on_replace: :nilify

    many_to_many :completed_sections, Section,
      join_through: "enrollment_section",
      on_replace: :delete

    many_to_many :completed_blocks, Block,
      join_through: "enrollment_block",
      on_replace: :delete

    timestamps()
  end

  ### ************ READ / QUERY FUNCTIONS *******************###

  def where_id(query \\ __MODULE__, enrollment_id),
    do: from(e in query, where: e.id == ^enrollment_id)

  def where_student(query \\ __MODULE__, student_id),
    do: from(e in query, where: e.student_id == ^student_id)

  def where_subject(query \\ __MODULE__, subject_id),
    do: from(e in query, where: e.subject_id == ^subject_id)

  def where_pending(query \\ __MODULE__, pending_state),
    do: from(e in query, where: e.pending == ^pending_state)

  def load_subject(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :subject)

  def load_cursor(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :block_cursor)

  def load_cursor_with_section(query = %Ecto.Query{}),
    do: Ecto.Query.preload(query, block_cursor: :section)

  def load_completed_sections(query = %Ecto.Query{}),
    do: Ecto.Query.preload(query, :completed_sections)

  def load_completed_blocks(query = %Ecto.Query{}),
    do: Ecto.Query.preload(query, :completed_blocks)

  ### ************ CHANGESET / INSERT FUNCTIONS *******************###

  def create_changeset(
        enrollment,
        %{subject_id: subject_id, student_id: _student_id} = params
      ) do
    first_block_for_cursor =
      from(s in Section,
        where: s.subject_id == ^subject_id,
        where: s.order_in_subject == 0,
        join: cb in Block,
        on: cb.section_id == s.id,
        where: cb.order_in_section == 0,
        select: cb
      )
      |> PGRepo.one()

    enrollment
    |> cast(params, ~w(student_id subject_id pending block_cursor_id completed)a)
    |> put_assoc(:block_cursor, first_block_for_cursor)
    |> put_assoc(:completed_sections, [])
    |> put_assoc(:completed_blocks, [])
    |> unique_constraint([:student_id, :subject_id], name: :student_id_subject_id_unique_index)
  end

  def consume_cursor_changeset(enrollment = %__MODULE__{}) do
    enrollment
    |> PGRepo.preload([:completed_blocks, :completed_sections, block_cursor: :section])
    |> do_consume_cursor_changeset()
  end

  def consume_cursor_changeset(enrollment_id) when is_binary(enrollment_id) do
    __MODULE__
    |> where_id(enrollment_id)
    |> load_completed_blocks()
    |> load_completed_sections()
    |> load_cursor_with_section()
    |> PGRepo.one()
    |> do_consume_cursor_changeset()
  end

  defp do_consume_cursor_changeset(enrollment) do
    if completed_block = enrollment.block_cursor do
      completed_blocks = [completed_block | enrollment.completed_blocks]

      completed_sections =
        maybe_add_section_to_completed_sections_list(
          completed_blocks,
          completed_block,
          enrollment
        )

      is_completed? = is_enrollment_completed?(completed_blocks, enrollment.subject_id)

      enrollment
      |> change()
      |> put_assoc(:completed_sections, completed_sections)
      |> put_assoc(:completed_blocks, completed_blocks)
      |> put_assoc(:block_cursor, nil)
      |> put_change(:completed, is_completed?)
    else
      enrollment
      |> change()
    end
  end

  defp is_enrollment_completed?(completed_blocks, enrollment_subject_id) do
    subject_blocks =
      Block
      |> Block.where_subject(enrollment_subject_id)
      |> PGRepo.all()

    Enum.all?(subject_blocks, fn subject_block ->
      Enum.find_value(completed_blocks, &(&1.id == subject_block.id))
    end)
  end

  defp maybe_add_section_to_completed_sections_list(completed_blocks, consumed_block, enrollment) do
    section_blocks =
      Block
      |> Block.where_section(consumed_block.section_id)
      |> PGRepo.all()

    section_completed? =
      Enum.all?(section_blocks, fn section_block ->
        Enum.find_value(completed_blocks, &(&1.id == section_block.id))
      end)

    case section_completed? do
      true -> [consumed_block.section | enrollment.completed_sections]
      false -> enrollment.completed_sections
    end
  end

  def new_cursor_changeset(enrollment_id, new_block_id) when is_binary(enrollment_id) do
    enrollment =
      __MODULE__
      |> where_id(enrollment_id)
      |> PGRepo.one()

    enrollment
    |> change
    |> new_cursor_changeset(new_block_id)
  end

  def new_cursor_changeset(changeset = %Ecto.Changeset{}, new_block_id) do
    new_block = Block |> where_id(new_block_id) |> PGRepo.one()

    changeset
    |> put_assoc(:block_cursor, new_block)
  end

  def replace_all_cursors_query(_, nil) do
    # Generate impossible query to avoid actually updating anything.
    from(e in __MODULE__,
      where: e.subject_id == ^Ecto.UUID.generate(),
      where: e.student_id == ^Ecto.UUID.generate(),
      update: [set: [block_cursor_id: nil]]
    )
  end

  # Will replace the cursor of all enrollments matching the old cursor
  def replace_all_cursors_query(
        %{subject_id: si} = old_cursor_block,
        %{subject_id: si} = new_cursor_block
      ) do
    from(
      e in __MODULE__,
      where: e.subject_id == ^old_cursor_block.subject_id,
      where: e.block_cursor_id == ^old_cursor_block.id,
      update: [
        set: [
          block_cursor_id: ^new_cursor_block.id
        ]
      ]
    )
  end

  def completed_changeset(enrollment) do
    enrollment
    |> cast(%{completed: true}, [:completed])
  end

  def update_changeset(enrollment, params \\ %{}) do
    enrollment
    |> cast(params, ~w(pending completed)a)
  end

  def delete_changeset(enrollment) do
    enrollment
    |> change()
  end
end
