defmodule TheArk.RolesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Roles` context.
  """

  @doc """
  Generate a role.
  """
  def role_fixture(attrs \\ %{}) do
    {:ok, role} =
      attrs
      |> Enum.into(%{
        contact_number: "some contact_number",
        name: "some name",
        role: "some role"
      })
      |> TheArk.Roles.create_role()

    role
  end
end
