defmodule TheArk.SerialsTest do
  use TheArk.DataCase

  alias TheArk.Serials

  describe "serials" do
    alias TheArk.Serials.Serial

    import TheArk.SerialsFixtures

    @invalid_attrs %{name: nil, number: nil}

    test "list_serials/0 returns all serials" do
      serial = serial_fixture()
      assert Serials.list_serials() == [serial]
    end

    test "get_serial!/1 returns the serial with given id" do
      serial = serial_fixture()
      assert Serials.get_serial!(serial.id) == serial
    end

    test "create_serial/1 with valid data creates a serial" do
      valid_attrs = %{name: "some name", number: 42}

      assert {:ok, %Serial{} = serial} = Serials.create_serial(valid_attrs)
      assert serial.name == "some name"
      assert serial.number == 42
    end

    test "create_serial/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Serials.create_serial(@invalid_attrs)
    end

    test "update_serial/2 with valid data updates the serial" do
      serial = serial_fixture()
      update_attrs = %{name: "some updated name", number: 43}

      assert {:ok, %Serial{} = serial} = Serials.update_serial(serial, update_attrs)
      assert serial.name == "some updated name"
      assert serial.number == 43
    end

    test "update_serial/2 with invalid data returns error changeset" do
      serial = serial_fixture()
      assert {:error, %Ecto.Changeset{}} = Serials.update_serial(serial, @invalid_attrs)
      assert serial == Serials.get_serial!(serial.id)
    end

    test "delete_serial/1 deletes the serial" do
      serial = serial_fixture()
      assert {:ok, %Serial{}} = Serials.delete_serial(serial)
      assert_raise Ecto.NoResultsError, fn -> Serials.get_serial!(serial.id) end
    end

    test "change_serial/1 returns a serial changeset" do
      serial = serial_fixture()
      assert %Ecto.Changeset{} = Serials.change_serial(serial)
    end
  end
end
