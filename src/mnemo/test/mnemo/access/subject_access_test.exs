defmodule Mnemo.Access.SubjectTest do
  use Mnemo.DataCase
  alias Mnemo.Access.{Subject, UserProperties}

  test "create/1 successfully creates a subject" do
    {:ok, student} = UserProperties.new_student("test@email.com")
    {:ok, _subject} = Subject.new_subject(student.email)
  end

  test "student_subjects/1 successfully retrieves student's subjects" do
    {:ok, student} = UserProperties.new_student("test@email.com")
    {:ok, subject_1} = Subject.new_subject(student.email)
    {:ok, subject_2} = Subject.new_subject(student.email)

    subjects = Subject.student_subjects(student.email)

    assert length(subjects) == 2
    assert subject_1 in subjects
    assert subject_2 in subjects
  end
end
