defmodule TheArk.RolesTest do
  use TheArk.DataCase

  alias TheArk.Roles

  describe "roles" do
    alias TheArk.Roles.Role

    import TheArk.RolesFixtures

    @invalid_attrs %{contact_number: nil, name: nil, role: nil}

    test "list_roles/0 returns all roles" do
      role = role_fixture()
      assert Roles.list_roles() == [role]
    end

    test "get_role!/1 returns the role with given id" do
      role = role_fixture()
      assert Roles.get_role!(role.id) == role
    end

    test "create_role/1 with valid data creates a role" do
      valid_attrs = %{contact_number: "some contact_number", name: "some name", role: "some role"}

      assert {:ok, %Role{} = role} = Roles.create_role(valid_attrs)
      assert role.contact_number == "some contact_number"
      assert role.name == "some name"
      assert role.role == "some role"
    end

    test "create_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Roles.create_role(@invalid_attrs)
    end

    test "update_role/2 with valid data updates the role" do
      role = role_fixture()
      update_attrs = %{contact_number: "some updated contact_number", name: "some updated name", role: "some updated role"}

      assert {:ok, %Role{} = role} = Roles.update_role(role, update_attrs)
      assert role.contact_number == "some updated contact_number"
      assert role.name == "some updated name"
      assert role.role == "some updated role"
    end

    test "update_role/2 with invalid data returns error changeset" do
      role = role_fixture()
      assert {:error, %Ecto.Changeset{}} = Roles.update_role(role, @invalid_attrs)
      assert role == Roles.get_role!(role.id)
    end

    test "delete_role/1 deletes the role" do
      role = role_fixture()
      assert {:ok, %Role{}} = Roles.delete_role(role)
      assert_raise Ecto.NoResultsError, fn -> Roles.get_role!(role.id) end
    end

    test "change_role/1 returns a role changeset" do
      role = role_fixture()
      assert %Ecto.Changeset{} = Roles.change_role(role)
    end
  end
end
