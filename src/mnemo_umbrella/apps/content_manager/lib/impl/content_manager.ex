defmodule ContentManager.Impl.ContentManager do
  def add_user(email) do
    SubjectAccess.add_user(email)

    SubjectAccess.all_users()
  end

  def all_users() do
    SubjectAccess.all_users()
  end
end
