defmodule TheArk.TestsTest do
  use TheArk.DataCase

  alias TheArk.Tests

  describe "tests" do
    alias TheArk.Tests.Test

    import TheArk.TestsFixtures

    @invalid_attrs %{subject: nil}

    test "list_tests/0 returns all tests" do
      test = test_fixture()
      assert Tests.list_tests() == [test]
    end

    test "get_test!/1 returns the test with given id" do
      test = test_fixture()
      assert Tests.get_test!(test.id) == test
    end

    test "create_test/1 with valid data creates a test" do
      valid_attrs = %{subject: "some subject"}

      assert {:ok, %Test{} = test} = Tests.create_test(valid_attrs)
      assert test.subject == "some subject"
    end

    test "create_test/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tests.create_test(@invalid_attrs)
    end

    test "update_test/2 with valid data updates the test" do
      test = test_fixture()
      update_attrs = %{subject: "some updated subject"}

      assert {:ok, %Test{} = test} = Tests.update_test(test, update_attrs)
      assert test.subject == "some updated subject"
    end

    test "update_test/2 with invalid data returns error changeset" do
      test = test_fixture()
      assert {:error, %Ecto.Changeset{}} = Tests.update_test(test, @invalid_attrs)
      assert test == Tests.get_test!(test.id)
    end

    test "delete_test/1 deletes the test" do
      test = test_fixture()
      assert {:ok, %Test{}} = Tests.delete_test(test)
      assert_raise Ecto.NoResultsError, fn -> Tests.get_test!(test.id) end
    end

    test "change_test/1 returns a test changeset" do
      test = test_fixture()
      assert %Ecto.Changeset{} = Tests.change_test(test)
    end
  end
end
