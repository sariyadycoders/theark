defmodule TheArk.OffdaysTest do
  use TheArk.DataCase

  alias TheArk.Offdays

  describe "offdays" do
    alias TheArk.Offdays.Offday

    import TheArk.OffdaysFixtures

    @invalid_attrs %{}

    test "list_offdays/0 returns all offdays" do
      offday = offday_fixture()
      assert Offdays.list_offdays() == [offday]
    end

    test "get_offday!/1 returns the offday with given id" do
      offday = offday_fixture()
      assert Offdays.get_offday!(offday.id) == offday
    end

    test "create_offday/1 with valid data creates a offday" do
      valid_attrs = %{}

      assert {:ok, %Offday{} = offday} = Offdays.create_offday(valid_attrs)
    end

    test "create_offday/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Offdays.create_offday(@invalid_attrs)
    end

    test "update_offday/2 with valid data updates the offday" do
      offday = offday_fixture()
      update_attrs = %{}

      assert {:ok, %Offday{} = offday} = Offdays.update_offday(offday, update_attrs)
    end

    test "update_offday/2 with invalid data returns error changeset" do
      offday = offday_fixture()
      assert {:error, %Ecto.Changeset{}} = Offdays.update_offday(offday, @invalid_attrs)
      assert offday == Offdays.get_offday!(offday.id)
    end

    test "delete_offday/1 deletes the offday" do
      offday = offday_fixture()
      assert {:ok, %Offday{}} = Offdays.delete_offday(offday)
      assert_raise Ecto.NoResultsError, fn -> Offdays.get_offday!(offday.id) end
    end

    test "change_offday/1 returns a offday changeset" do
      offday = offday_fixture()
      assert %Ecto.Changeset{} = Offdays.change_offday(offday)
    end
  end
end
