defmodule Mnemo.BlockTest do
  use Mnemo.DataCase
  alias Mnemo.Access.Schemas.{Block}
  alias Test.Fixtures
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  test "created blocks increase in section_order" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
    {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})
    {:ok, block_0} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})
    {:ok, block_1} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

    assert block_0.order_in_section == 0
    assert block_1.order_in_section == 1
  end

  test "created blocks increase in section_order, resetting in new sections" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
    {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})

    {:ok, block_s0_0} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

    {:ok, block_s0_1} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

    {:ok, section_1} = Fixtures.create(:section, %{subject_id: subject.id})

    {:ok, block_s1_0} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_1.id})

    {:ok, block_s1_1} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_1.id})

    assert block_s0_0.order_in_section == 0
    assert block_s0_1.order_in_section == 1
    assert block_s1_0.order_in_section == 0
    assert block_s1_1.order_in_section == 1
  end

  test "removing a block resets the order_in_section of all other blocks in section" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
    {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})
    {:ok, block_0} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})
    {:ok, block_1} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})
    {:ok, block_2} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

    {:ok, _deleted_block} = block_1 |> Block.delete_changeset() |> Repo.delete()
    {:ok, block_3} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

    updated_block_0 = Block |> Block.where_id(block_0.id) |> PGRepo.one()
    updated_block_2 = Block |> Block.where_id(block_2.id) |> PGRepo.one()

    assert updated_block_0.order_in_section == 0
    assert updated_block_2.order_in_section == 1
    assert block_3.order_in_section == 2
  end

  test "reordering block upwards correctly reorders other blocks" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
    {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})
    {:ok, block_0} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})
    {:ok, block_1} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})
    {:ok, block_2} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

    {:ok, block_0_r} = block_0 |> Block.update_order_changeset(2) |> PGRepo.update()

    updated_block_1 = PGRepo.get(Block, block_1.id)
    updated_block_2 = PGRepo.get(Block, block_2.id)

    assert block_0_r.order_in_section == 2
    assert updated_block_1.order_in_section == 0
    assert updated_block_2.order_in_section == 1
  end

  test "reordering block downwards correctly reorders other blocks" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
    {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})
    {:ok, block_0} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})
    {:ok, block_1} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})
    {:ok, block_2} = Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

    {:ok, block_2_r} = block_2 |> Block.update_order_changeset(0) |> PGRepo.update()

    updated_block_0 = PGRepo.get(Block, block_0.id)
    updated_block_1 = PGRepo.get(Block, block_1.id)

    assert block_2_r.order_in_section == 0
    assert updated_block_0.order_in_section == 1
    assert updated_block_1.order_in_section == 2
  end

  test "reordering block upwards into new section correctly reorders other blocks and resets old section blocks" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
    {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})

    {:ok, block_s0_0} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

    {:ok, block_s0_1} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

    {:ok, block_s0_2} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

    {:ok, section_1} = Fixtures.create(:section, %{subject_id: subject.id})

    {:ok, block_s1_0} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_1.id})

    {:ok, block_s1_1} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_1.id})

    {:ok, block_s1_2} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_1.id})

    {:ok, block_s0_1_r} =
      block_s0_1 |> Block.update_order_changeset(1, section_1.id) |> PGRepo.update()

    updated_block_s0_0 = PGRepo.get(Block, block_s0_0.id)
    updated_block_s0_2 = PGRepo.get(Block, block_s0_2.id)
    updated_block_s1_0 = PGRepo.get(Block, block_s1_0.id)
    updated_block_s1_1 = PGRepo.get(Block, block_s1_1.id)
    updated_block_s1_2 = PGRepo.get(Block, block_s1_2.id)

    assert block_s0_1_r.order_in_section == 1
    assert block_s0_1_r.section_id == section_1.id
    assert updated_block_s0_0.order_in_section == 0
    assert updated_block_s0_2.order_in_section == 1
    assert updated_block_s1_0.order_in_section == 0
    assert updated_block_s1_1.order_in_section == 2
    assert updated_block_s1_2.order_in_section == 3
  end

  test "next_block/1 returns the next block, regardless of section" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
    {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})

    {:ok, block_s0_0} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

    {:ok, block_s0_1} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

    {:ok, block_s0_2} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_0.id})

    {:ok, section_1} = Fixtures.create(:section, %{subject_id: subject.id})

    {:ok, block_s1_0} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_1.id})

    {:ok, block_s1_1} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_1.id})

    {:ok, block_s1_2} =
      Fixtures.create(:block, %{subject_id: subject.id, section_id: section_1.id})

    nb = Block.next_block(block_s0_0)
    assert nb.id == block_s0_1.id
    nb = Block.next_block(block_s0_1)
    assert nb.id == block_s0_2.id
    nb = Block.next_block(block_s0_2)
    assert nb.id == block_s1_0.id
    nb = Block.next_block(block_s1_0)
    assert nb.id == block_s1_1.id
    nb = Block.next_block(block_s1_1)
    assert nb.id == block_s1_2.id
    nb = Block.next_block(block_s1_2)
    assert nb == nil
  end
end
