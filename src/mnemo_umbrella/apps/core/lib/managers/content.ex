defmodule Core.Managers.Content do
  def add_user(email) do
    Core.Access.Subject.add_user(email)
  end

  def users() do
    Core.Access.Subject.users()
  end
end
