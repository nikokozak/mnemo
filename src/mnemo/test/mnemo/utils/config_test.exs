defmodule Mnemo.Utils.ConfigTest do
  use Mnemo.DataCase
  alias Mnemo.Utils.Config

  describe "date" do
    test "returns today's date if nothing is set" do
      Config.reset()
      assert Config.date() == Date.utc_today()
    end

    test "sets date and retrieves new date" do
      Config.reset()
      new_date = Date.add(Date.utc_today(), 1)

      Config.set_date(new_date)

      assert Config.date() == new_date
    end
  end
end
