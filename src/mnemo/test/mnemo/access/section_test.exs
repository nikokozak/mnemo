defmodule Mnemo.SectionTest do
  use Mnemo.DataCase
  alias Mnemo.Access.Schemas.{Section}
  alias Test.Fixtures
  alias Mnemo.Resources.Postgres.Repo, as: PGRepo

  test "created sections increase in section_order" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
    {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})
    {:ok, section_1} = Fixtures.create(:section, %{subject_id: subject.id})

    assert section_0.order_in_subject == 0
    assert section_1.order_in_subject == 1
  end

  test "removing a section resets the section_order of all other sections in subject" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
    {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})
    {:ok, section_1} = Fixtures.create(:section, %{subject_id: subject.id})
    {:ok, section_2} = Fixtures.create(:section, %{subject_id: subject.id})

    {:ok, _deleted_section} = section_1 |> Section.delete_changeset() |> Repo.delete()
    {:ok, section_3} = Fixtures.create(:section, %{subject_id: subject.id})

    updated_section_0 = Section |> Section.where_id(section_0.id) |> PGRepo.one()
    updated_section_2 = Section |> Section.where_id(section_2.id) |> PGRepo.one()

    assert updated_section_0.order_in_subject == 0
    assert updated_section_2.order_in_subject == 1
    assert section_3.order_in_subject == 2
  end

  test "reordering section upwards correctly reorders other sections" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
    {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})
    {:ok, section_1} = Fixtures.create(:section, %{subject_id: subject.id})
    {:ok, section_2} = Fixtures.create(:section, %{subject_id: subject.id})

    {:ok, section_0_r} = section_0 |> Section.update_order_changeset(2) |> PGRepo.update()

    updated_section_1 = PGRepo.get(Section, section_1.id)
    updated_section_2 = PGRepo.get(Section, section_2.id)

    assert section_0_r.order_in_subject == 2
    assert updated_section_1.order_in_subject == 0
    assert updated_section_2.order_in_subject == 1
  end

  test "reordering section downwards correctly reorders other sections" do
    {:ok, student} = Fixtures.create(:student)
    {:ok, subject} = Fixtures.create(:subject, %{student_id: student.id})
    {:ok, section_0} = Fixtures.create(:section, %{subject_id: subject.id})
    {:ok, section_1} = Fixtures.create(:section, %{subject_id: subject.id})
    {:ok, section_2} = Fixtures.create(:section, %{subject_id: subject.id})

    {:ok, section_2_r} = section_2 |> Section.update_order_changeset(0) |> PGRepo.update()

    updated_section_0 = PGRepo.get(Section, section_0.id)
    updated_section_1 = PGRepo.get(Section, section_1.id)

    assert section_2_r.order_in_subject == 0
    assert updated_section_0.order_in_subject == 1
    assert updated_section_1.order_in_subject == 2
  end
end
