defmodule TheArk.SlosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Slos` context.
  """

  @doc """
  Generate a slo.
  """
  def slo_fixture(attrs \\ %{}) do
    {:ok, slo} =
      attrs
      |> Enum.into(%{
        description: "some description"
      })
      |> TheArk.Slos.create_slo()

    slo
  end
end
