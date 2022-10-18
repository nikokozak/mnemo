defmodule MnemoWeb.CommandView do
  use MnemoWeb, :view

  def render("subject.json", %{subject: subject}) do
    %{id: subject.id}
  end
end
