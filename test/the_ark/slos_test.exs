defmodule TheArk.SlosTest do
  use TheArk.DataCase

  alias TheArk.Slos

  describe "slos" do
    alias TheArk.Slos.Slo

    import TheArk.SlosFixtures

    @invalid_attrs %{description: nil}

    test "list_slos/0 returns all slos" do
      slo = slo_fixture()
      assert Slos.list_slos() == [slo]
    end

    test "get_slo!/1 returns the slo with given id" do
      slo = slo_fixture()
      assert Slos.get_slo!(slo.id) == slo
    end

    test "create_slo/1 with valid data creates a slo" do
      valid_attrs = %{description: "some description"}

      assert {:ok, %Slo{} = slo} = Slos.create_slo(valid_attrs)
      assert slo.description == "some description"
    end

    test "create_slo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Slos.create_slo(@invalid_attrs)
    end

    test "update_slo/2 with valid data updates the slo" do
      slo = slo_fixture()
      update_attrs = %{description: "some updated description"}

      assert {:ok, %Slo{} = slo} = Slos.update_slo(slo, update_attrs)
      assert slo.description == "some updated description"
    end

    test "update_slo/2 with invalid data returns error changeset" do
      slo = slo_fixture()
      assert {:error, %Ecto.Changeset{}} = Slos.update_slo(slo, @invalid_attrs)
      assert slo == Slos.get_slo!(slo.id)
    end

    test "delete_slo/1 deletes the slo" do
      slo = slo_fixture()
      assert {:ok, %Slo{}} = Slos.delete_slo(slo)
      assert_raise Ecto.NoResultsError, fn -> Slos.get_slo!(slo.id) end
    end

    test "change_slo/1 returns a slo changeset" do
      slo = slo_fixture()
      assert %Ecto.Changeset{} = Slos.change_slo(slo)
    end
  end
end
