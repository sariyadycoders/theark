defmodule TheArk.OffdaysFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Offdays` context.
  """

  @doc """
  Generate a offday.
  """
  def offday_fixture(attrs \\ %{}) do
    {:ok, offday} =
      attrs
      |> Enum.into(%{

      })
      |> TheArk.Offdays.create_offday()

    offday
  end
end
