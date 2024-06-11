defmodule TheArk.Tests do
  @moduledoc """
  The Tests context.
  """

  import Ecto.Query, warn: false
  alias TheArk.Repo

  alias TheArk.{
    Tests.Test,
    Students
  }

  @doc """
  Returns the list of tests.

  ## Examples

      iex> list_tests()
      [%Test{}, ...]

  """
  def list_tests do
    Repo.all(Test)
  end

  @doc """
  Gets a single test.

  Raises `Ecto.NoResultsError` if the Test does not exist.

  ## Examples

      iex> get_test!(123)
      %Test{}

      iex> get_test!(456)
      ** (Ecto.NoResultsError)

  """
  def get_test!(id), do: Repo.get!(Test, id)

  @doc """
  Creates a test.

  ## Examples

      iex> create_test(%{field: value})
      {:ok, %Test{}}

      iex> create_test(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_test(attrs \\ %{}) do
    %Test{}
    |> Test.changeset(attrs)
    |> Repo.insert()
  end

  def create_class_test(attrs \\ %{}) do
    %Test{}
    |> Test.changeset(attrs)
    |> Repo.insert()
    |> create_test_students()
  end

  def create_test_students({:ok, test} = success) do
    student_ids = Students.get_all_active_students_ids(test.class_id)

    for id <- student_ids do
      create_test(%{
        subject: test.subject,
        total_marks: test.total_marks,
        date_of_test: test.date_of_test,
        class_id: test.class_id,
        student_id: id
      })
    end

    success
  end

  def create_test_students({:error, _} = error) do
    error
  end

  @doc """
  Updates a test.

  ## Examples

      iex> update_test(test, %{field: new_value})
      {:ok, %Test{}}

      iex> update_test(test, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_test(%Test{} = test, attrs) do
    test
    |> Test.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a test.

  ## Examples

      iex> delete_test(test)
      {:ok, %Test{}}

      iex> delete_test(test)
      {:error, %Ecto.Changeset{}}

  """
  def delete_test(%Test{} = test) do
    Repo.delete(test)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking test changes.

  ## Examples

      iex> change_test(test)
      %Ecto.Changeset{data: %Test{}}

  """
  def change_test(%Test{} = test, attrs \\ %{}) do
    Test.changeset(test, attrs)
  end
end
