defmodule Mnemo.Utils.Config do
  use Agent

  @moduledoc """
  An in-memory config storage for the running application.
  """

  defp base_config() do
    %{
      date: Date.utc_today()
    }
  end

  def start_link(_init) do
    Agent.start_link(fn -> base_config() end, name: __MODULE__)
  end

  def date() do
    if Mix.env() == :dev || Mix.env() == :test do
      Agent.get(__MODULE__, &Map.get(&1, :date))
    else
      Date.utc_today()
    end
  end

  def set_date(new_date) do
    Agent.update(__MODULE__, &Map.put(&1, :date, new_date))
  end

  def reset() do
    Agent.update(__MODULE__, fn _val -> base_config() end)
  end
end
