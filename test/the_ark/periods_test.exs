defmodule TheArk.PeriodsTest do
  use TheArk.DataCase

  alias TheArk.Periods

  describe "periods" do
    alias TheArk.Periods.Perid

    import TheArk.PeriodsFixtures

    @invalid_attrs %{period_number: nil, subject: nil}

    test "list_periods/0 returns all periods" do
      perid = perid_fixture()
      assert Periods.list_periods() == [perid]
    end

    test "get_perid!/1 returns the perid with given id" do
      perid = perid_fixture()
      assert Periods.get_perid!(perid.id) == perid
    end

    test "create_perid/1 with valid data creates a perid" do
      valid_attrs = %{period_number: 42, subject: "some subject"}

      assert {:ok, %Perid{} = perid} = Periods.create_perid(valid_attrs)
      assert perid.period_number == 42
      assert perid.subject == "some subject"
    end

    test "create_perid/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Periods.create_perid(@invalid_attrs)
    end

    test "update_perid/2 with valid data updates the perid" do
      perid = perid_fixture()
      update_attrs = %{period_number: 43, subject: "some updated subject"}

      assert {:ok, %Perid{} = perid} = Periods.update_perid(perid, update_attrs)
      assert perid.period_number == 43
      assert perid.subject == "some updated subject"
    end

    test "update_perid/2 with invalid data returns error changeset" do
      perid = perid_fixture()
      assert {:error, %Ecto.Changeset{}} = Periods.update_perid(perid, @invalid_attrs)
      assert perid == Periods.get_perid!(perid.id)
    end

    test "delete_perid/1 deletes the perid" do
      perid = perid_fixture()
      assert {:ok, %Perid{}} = Periods.delete_perid(perid)
      assert_raise Ecto.NoResultsError, fn -> Periods.get_perid!(perid.id) end
    end

    test "change_perid/1 returns a perid changeset" do
      perid = perid_fixture()
      assert %Ecto.Changeset{} = Periods.change_perid(perid)
    end
  end
end
