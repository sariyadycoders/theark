defmodule TheArk.AttendancesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Attendances` context.
  """

  @doc """
  Generate a attendance.
  """
  def attendance_fixture(attrs \\ %{}) do
    {:ok, attendance} =
      attrs
      |> Enum.into(%{

      })
      |> TheArk.Attendances.create_attendance()

    attendance
  end
end
