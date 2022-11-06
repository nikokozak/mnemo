defmodule MnemoWeb.Live.Subject.Editor do
  use MnemoWeb, :live_view

  def mount(%{"subject_id" => subject_id}, _session, socket) do
    {:ok, assign(socket, subject_id: subject_id)}
  end
end
