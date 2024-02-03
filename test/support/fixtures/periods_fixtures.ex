defmodule TheArk.PeriodsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Periods` context.
  """

  @doc """
  Generate a perid.
  """
  def perid_fixture(attrs \\ %{}) do
    {:ok, perid} =
      attrs
      |> Enum.into(%{
        period_number: 42,
        subject: "some subject"
      })
      |> TheArk.Periods.create_perid()

    perid
  end
end
