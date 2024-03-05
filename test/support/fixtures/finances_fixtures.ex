defmodule TheArk.FinancesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Finances` context.
  """

  @doc """
  Generate a finance.
  """
  def finance_fixture(attrs \\ %{}) do
    {:ok, finance} =
      attrs
      |> Enum.into(%{})
      |> TheArk.Finances.create_finance()

    finance
  end
end
