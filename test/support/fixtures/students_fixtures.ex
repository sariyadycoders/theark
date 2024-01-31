defmodule TheArk.StudentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Students` context.
  """

  @doc """
  Generate a student.
  """
  def student_fixture(attrs \\ %{}) do
    {:ok, student} =
      attrs
      |> Enum.into(%{
        age: 42,
        class: "some class",
        father_name: "some father_name",
        name: "some name"
      })
      |> TheArk.Students.create_student()

    student
  end
end
