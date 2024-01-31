defmodule TheArk.TeachersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Teachers` context.
  """

  @doc """
  Generate a teacher.
  """
  def teacher_fixture(attrs \\ %{}) do
    {:ok, teacher} =
      attrs
      |> Enum.into(%{
        date_of_joining: ~D[2024-01-22],
        date_of_leaving: ~D[2024-01-22],
        name: "some name",
        residence: "some residence"
      })
      |> TheArk.Teachers.create_teacher()

    teacher
  end
end
