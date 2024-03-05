defmodule TheArk.FinancesTest do
  use TheArk.DataCase

  alias TheArk.Finances

  describe "finances" do
    alias TheArk.Finances.Finance

    import TheArk.FinancesFixtures

    @invalid_attrs %{}

    test "list_finances/0 returns all finances" do
      finance = finance_fixture()
      assert Finances.list_finances() == [finance]
    end

    test "get_finance!/1 returns the finance with given id" do
      finance = finance_fixture()
      assert Finances.get_finance!(finance.id) == finance
    end

    test "create_finance/1 with valid data creates a finance" do
      valid_attrs = %{}

      assert {:ok, %Finance{} = finance} = Finances.create_finance(valid_attrs)
    end

    test "create_finance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finances.create_finance(@invalid_attrs)
    end

    test "update_finance/2 with valid data updates the finance" do
      finance = finance_fixture()
      update_attrs = %{}

      assert {:ok, %Finance{} = finance} = Finances.update_finance(finance, update_attrs)
    end

    test "update_finance/2 with invalid data returns error changeset" do
      finance = finance_fixture()
      assert {:error, %Ecto.Changeset{}} = Finances.update_finance(finance, @invalid_attrs)
      assert finance == Finances.get_finance!(finance.id)
    end

    test "delete_finance/1 deletes the finance" do
      finance = finance_fixture()
      assert {:ok, %Finance{}} = Finances.delete_finance(finance)
      assert_raise Ecto.NoResultsError, fn -> Finances.get_finance!(finance.id) end
    end

    test "change_finance/1 returns a finance changeset" do
      finance = finance_fixture()
      assert %Ecto.Changeset{} = Finances.change_finance(finance)
    end
  end
end
