defmodule TheArk.ClassesTest do
  use TheArk.DataCase

  alias TheArk.Classes

  describe "classes" do
    alias TheArk.Classes.Class

    import TheArk.ClassesFixtures

    @invalid_attrs %{incharge: nil, name: nil, total_students: nil}

    test "list_classes/0 returns all classes" do
      class = class_fixture()
      assert Classes.list_classes() == [class]
    end

    test "get_class!/1 returns the class with given id" do
      class = class_fixture()
      assert Classes.get_class!(class.id) == class
    end

    test "create_class/1 with valid data creates a class" do
      valid_attrs = %{incharge: "some incharge", name: "some name", total_students: 42}

      assert {:ok, %Class{} = class} = Classes.create_class(valid_attrs)
      assert class.incharge == "some incharge"
      assert class.name == "some name"
      assert class.total_students == 42
    end

    test "create_class/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Classes.create_class(@invalid_attrs)
    end

    test "update_class/2 with valid data updates the class" do
      class = class_fixture()
      update_attrs = %{incharge: "some updated incharge", name: "some updated name", total_students: 43}

      assert {:ok, %Class{} = class} = Classes.update_class(class, update_attrs)
      assert class.incharge == "some updated incharge"
      assert class.name == "some updated name"
      assert class.total_students == 43
    end

    test "update_class/2 with invalid data returns error changeset" do
      class = class_fixture()
      assert {:error, %Ecto.Changeset{}} = Classes.update_class(class, @invalid_attrs)
      assert class == Classes.get_class!(class.id)
    end

    test "delete_class/1 deletes the class" do
      class = class_fixture()
      assert {:ok, %Class{}} = Classes.delete_class(class)
      assert_raise Ecto.NoResultsError, fn -> Classes.get_class!(class.id) end
    end

    test "change_class/1 returns a class changeset" do
      class = class_fixture()
      assert %Ecto.Changeset{} = Classes.change_class(class)
    end
  end
end
