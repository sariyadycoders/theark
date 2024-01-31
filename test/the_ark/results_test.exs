defmodule TheArk.ResultsTest do
  use TheArk.DataCase

  alias TheArk.Results

  describe "results" do
    alias TheArk.Results.Result

    import TheArk.ResultsFixtures

    @invalid_attrs %{name: nil, obtained_marks: nil, total_marks: nil}

    test "list_results/0 returns all results" do
      result = result_fixture()
      assert Results.list_results() == [result]
    end

    test "get_result!/1 returns the result with given id" do
      result = result_fixture()
      assert Results.get_result!(result.id) == result
    end

    test "create_result/1 with valid data creates a result" do
      valid_attrs = %{name: "some name", obtained_marks: 42, total_marks: 42}

      assert {:ok, %Result{} = result} = Results.create_result(valid_attrs)
      assert result.name == "some name"
      assert result.obtained_marks == 42
      assert result.total_marks == 42
    end

    test "create_result/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Results.create_result(@invalid_attrs)
    end

    test "update_result/2 with valid data updates the result" do
      result = result_fixture()
      update_attrs = %{name: "some updated name", obtained_marks: 43, total_marks: 43}

      assert {:ok, %Result{} = result} = Results.update_result(result, update_attrs)
      assert result.name == "some updated name"
      assert result.obtained_marks == 43
      assert result.total_marks == 43
    end

    test "update_result/2 with invalid data returns error changeset" do
      result = result_fixture()
      assert {:error, %Ecto.Changeset{}} = Results.update_result(result, @invalid_attrs)
      assert result == Results.get_result!(result.id)
    end

    test "delete_result/1 deletes the result" do
      result = result_fixture()
      assert {:ok, %Result{}} = Results.delete_result(result)
      assert_raise Ecto.NoResultsError, fn -> Results.get_result!(result.id) end
    end

    test "change_result/1 returns a result changeset" do
      result = result_fixture()
      assert %Ecto.Changeset{} = Results.change_result(result)
    end
  end
end
