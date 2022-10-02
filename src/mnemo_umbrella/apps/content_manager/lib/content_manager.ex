defmodule ContentManager do
  alias ContentManager.Impl.ContentManager, as: CM

  defdelegate add_user(email), to: CM

  defdelegate all_users(), to: CM
end
