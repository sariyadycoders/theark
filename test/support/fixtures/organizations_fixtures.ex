defmodule TheArk.OrganizationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Organizations` context.
  """

  @doc """
  Generate a organization.
  """
  def organization_fixture(attrs \\ %{}) do
    {:ok, organization} =
      attrs
      |> Enum.into(%{
        name: "some name",
        number_of_staff: 42,
        number_of_students: 42,
        number_of_years: 42
      })
      |> TheArk.Organizations.create_organization()

    organization
  end
end
