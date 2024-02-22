defmodule TheArk.ClassresultsTest do
  use TheArk.DataCase

  alias TheArk.Classresults

  describe "classresults" do
    alias TheArk.Classresults.Classresult

    import TheArk.ClassresultsFixtures

    @invalid_attrs %{}

    test "list_classresults/0 returns all classresults" do
      classresult = classresult_fixture()
      assert Classresults.list_classresults() == [classresult]
    end

    test "get_classresult!/1 returns the classresult with given id" do
      classresult = classresult_fixture()
      assert Classresults.get_classresult!(classresult.id) == classresult
    end

    test "create_classresult/1 with valid data creates a classresult" do
      valid_attrs = %{}

      assert {:ok, %Classresult{} = classresult} = Classresults.create_classresult(valid_attrs)
    end

    test "create_classresult/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Classresults.create_classresult(@invalid_attrs)
    end

    test "update_classresult/2 with valid data updates the classresult" do
      classresult = classresult_fixture()
      update_attrs = %{}

      assert {:ok, %Classresult{} = classresult} =
               Classresults.update_classresult(classresult, update_attrs)
    end

    test "update_classresult/2 with invalid data returns error changeset" do
      classresult = classresult_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Classresults.update_classresult(classresult, @invalid_attrs)

      assert classresult == Classresults.get_classresult!(classresult.id)
    end

    test "delete_classresult/1 deletes the classresult" do
      classresult = classresult_fixture()
      assert {:ok, %Classresult{}} = Classresults.delete_classresult(classresult)
      assert_raise Ecto.NoResultsError, fn -> Classresults.get_classresult!(classresult.id) end
    end

    test "change_classresult/1 returns a classresult changeset" do
      classresult = classresult_fixture()
      assert %Ecto.Changeset{} = Classresults.change_classresult(classresult)
    end
  end
end
