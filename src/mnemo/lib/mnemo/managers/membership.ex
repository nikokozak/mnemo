defmodule Mnemo.Managers.Membership do
  alias Mnemo.Access

  def new_student(email) do
    Access.UserProperties.new_student(email)
  end

  def students() do
    Access.UserProperties.students()
  end
end
