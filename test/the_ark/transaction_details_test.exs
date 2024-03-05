defmodule TheArk.Transaction_detailsTest do
  use TheArk.DataCase

  alias TheArk.Transaction_details

  describe "transaction_details" do
    alias TheArk.Transaction_details.Transaction_detail

    import TheArk.Transaction_detailsFixtures

    @invalid_attrs %{}

    test "list_transaction_details/0 returns all transaction_details" do
      transaction_detail = transaction_detail_fixture()
      assert Transaction_details.list_transaction_details() == [transaction_detail]
    end

    test "get_transaction_detail!/1 returns the transaction_detail with given id" do
      transaction_detail = transaction_detail_fixture()

      assert Transaction_details.get_transaction_detail!(transaction_detail.id) ==
               transaction_detail
    end

    test "create_transaction_detail/1 with valid data creates a transaction_detail" do
      valid_attrs = %{}

      assert {:ok, %Transaction_detail{} = transaction_detail} =
               Transaction_details.create_transaction_detail(valid_attrs)
    end

    test "create_transaction_detail/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Transaction_details.create_transaction_detail(@invalid_attrs)
    end

    test "update_transaction_detail/2 with valid data updates the transaction_detail" do
      transaction_detail = transaction_detail_fixture()
      update_attrs = %{}

      assert {:ok, %Transaction_detail{} = transaction_detail} =
               Transaction_details.update_transaction_detail(transaction_detail, update_attrs)
    end

    test "update_transaction_detail/2 with invalid data returns error changeset" do
      transaction_detail = transaction_detail_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Transaction_details.update_transaction_detail(transaction_detail, @invalid_attrs)

      assert transaction_detail ==
               Transaction_details.get_transaction_detail!(transaction_detail.id)
    end

    test "delete_transaction_detail/1 deletes the transaction_detail" do
      transaction_detail = transaction_detail_fixture()

      assert {:ok, %Transaction_detail{}} =
               Transaction_details.delete_transaction_detail(transaction_detail)

      assert_raise Ecto.NoResultsError, fn ->
        Transaction_details.get_transaction_detail!(transaction_detail.id)
      end
    end

    test "change_transaction_detail/1 returns a transaction_detail changeset" do
      transaction_detail = transaction_detail_fixture()
      assert %Ecto.Changeset{} = Transaction_details.change_transaction_detail(transaction_detail)
    end
  end
end
