defmodule TheArk.NotesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Notes` context.
  """

  @doc """
  Generate a note.
  """
  def note_fixture(attrs \\ %{}) do
    {:ok, note} =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: "some title"
      })
      |> TheArk.Notes.create_note()

    note
  end
end
