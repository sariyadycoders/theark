defmodule TheArk.ClassresultsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Classresults` context.
  """

  @doc """
  Generate a classresult.
  """
  def classresult_fixture(attrs \\ %{}) do
    {:ok, classresult} =
      attrs
      |> Enum.into(%{})
      |> TheArk.Classresults.create_classresult()

    classresult
  end
end
