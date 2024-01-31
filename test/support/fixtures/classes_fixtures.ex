defmodule TheArk.ClassesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Classes` context.
  """

  @doc """
  Generate a class.
  """
  def class_fixture(attrs \\ %{}) do
    {:ok, class} =
      attrs
      |> Enum.into(%{
        incharge: "some incharge",
        name: "some name",
        total_students: 42
      })
      |> TheArk.Classes.create_class()

    class
  end
end
