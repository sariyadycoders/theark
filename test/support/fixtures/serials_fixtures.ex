defmodule TheArk.SerialsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Serials` context.
  """

  @doc """
  Generate a serial.
  """
  def serial_fixture(attrs \\ %{}) do
    {:ok, serial} =
      attrs
      |> Enum.into(%{
        name: "some name",
        number: 42
      })
      |> TheArk.Serials.create_serial()

    serial
  end
end
