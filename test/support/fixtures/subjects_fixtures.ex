defmodule TheArk.SubjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Subjects` context.
  """

  @doc """
  Generate a subject.
  """
  def subject_fixture(attrs \\ %{}) do
    {:ok, subject} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> TheArk.Subjects.create_subject()

    subject
  end
end
