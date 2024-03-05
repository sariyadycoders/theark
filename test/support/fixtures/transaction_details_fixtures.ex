defmodule TheArk.Transaction_detailsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TheArk.Transaction_details` context.
  """

  @doc """
  Generate a transaction_detail.
  """
  def transaction_detail_fixture(attrs \\ %{}) do
    {:ok, transaction_detail} =
      attrs
      |> Enum.into(%{})
      |> TheArk.Transaction_details.create_transaction_detail()

    transaction_detail
  end
end
