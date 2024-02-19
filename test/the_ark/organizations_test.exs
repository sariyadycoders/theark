defmodule TheArk.OrganizationsTest do
  use TheArk.DataCase

  alias TheArk.Organizations

  describe "organizations" do
    alias TheArk.Organizations.Organization

    import TheArk.OrganizationsFixtures

    @invalid_attrs %{name: nil, number_of_staff: nil, number_of_students: nil, number_of_years: nil}

    test "list_organizations/0 returns all organizations" do
      organization = organization_fixture()
      assert Organizations.list_organizations() == [organization]
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = organization_fixture()
      assert Organizations.get_organization!(organization.id) == organization
    end

    test "create_organization/1 with valid data creates a organization" do
      valid_attrs = %{name: "some name", number_of_staff: 42, number_of_students: 42, number_of_years: 42}

      assert {:ok, %Organization{} = organization} = Organizations.create_organization(valid_attrs)
      assert organization.name == "some name"
      assert organization.number_of_staff == 42
      assert organization.number_of_students == 42
      assert organization.number_of_years == 42
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = organization_fixture()
      update_attrs = %{name: "some updated name", number_of_staff: 43, number_of_students: 43, number_of_years: 43}

      assert {:ok, %Organization{} = organization} = Organizations.update_organization(organization, update_attrs)
      assert organization.name == "some updated name"
      assert organization.number_of_staff == 43
      assert organization.number_of_students == 43
      assert organization.number_of_years == 43
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = organization_fixture()
      assert {:error, %Ecto.Changeset{}} = Organizations.update_organization(organization, @invalid_attrs)
      assert organization == Organizations.get_organization!(organization.id)
    end

    test "delete_organization/1 deletes the organization" do
      organization = organization_fixture()
      assert {:ok, %Organization{}} = Organizations.delete_organization(organization)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_organization!(organization.id) end
    end

    test "change_organization/1 returns a organization changeset" do
      organization = organization_fixture()
      assert %Ecto.Changeset{} = Organizations.change_organization(organization)
    end
  end
end
