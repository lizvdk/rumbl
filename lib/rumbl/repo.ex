defmodule Rumbl.Repo do

  @moduledoc """
  In memory repository
  """

  def all(Rumbl.User) do
    [%Rumbl.User{id: "1", name: "Ada Lovelace", username: "alovelace", password: "Algorithm1"},
     %Rumbl.User{id: "2", name: "Grace Hopper", username: "ghopper", password: "COBOL"},
     %Rumbl.User{id: "3", name: "Margaret Hamilton", username: "mhamilton", password: "Apollo11"}]
  end
  def all(_modue), do: []

  def get(module, id) do
    Enum.find all(module), fn map -> map.id == id end
  end

  def get_by(module, params) do
    Enum.find all(module), fn map ->
      Enum.all?(params, fn {key, val} -> Map.get(map, key) == val end)
    end
  end
end
