defmodule TheArk.Results do
  @moduledoc """
  The Results context.
  """

  import Ecto.Query, warn: false
  alias TheArk.Repo

  alias TheArk.Results.Result
  alias TheArk.Subjects
  alias TheArk.Classes

  @doc """
  Returns the list of results.

  ## Examples

      iex> list_results()
      [%Result{}, ...]

  """
  def list_results do
    Repo.all(Result)
  end

  @doc """
  Gets a single result.

  Raises `Ecto.NoResultsError` if the Result does not exist.

  ## Examples

      iex> get_result!(123)
      %Result{}

      iex> get_result!(456)
      ** (Ecto.NoResultsError)

  """
  def get_result!(id), do: Repo.get!(Result, id)

  def get_result_of_student(student, term, subject) do
    subject_id = (Subjects.get_subject_for_result_edition(student, subject)).id
    Repo.one(from r in Result, where: r.name== ^term and r.subject_id == ^subject_id)
  end

  @doc """
  Creates a result.

  ## Examples

      iex> create_result(%{field: value})
      {:ok, %Result{}}

      iex> create_result(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_result(attrs \\ %{}) do
    %Result{}
    |> Result.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a result.

  ## Examples

      iex> update_result(result, %{field: new_value})
      {:ok, %Result{}}

      iex> update_result(result, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_result(%Result{} = result, attrs) do
    result
    |> Result.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a result.

  ## Examples

      iex> delete_result(result)
      {:ok, %Result{}}

      iex> delete_result(result)
      {:error, %Ecto.Changeset{}}

  """
  def delete_result(%Result{} = result) do
    Repo.delete(result)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking result changes.

  ## Examples

      iex> change_result(result)
      %Ecto.Changeset{data: %Result{}}

  """
  def change_result(%Result{} = result, attrs \\ %{}) do
    Result.changeset(result, attrs)
  end

  def result_changeset_for_result_edition(student, term, subject) do
    result = get_result_of_student(student, term, subject)

    change_result(result, %{})
  end

  def prepare_class_results(id) do
    class = Classes.get_class!(id)

    for class_subject <- class.subjects do
      for result_name <- Classes.make_list_of_terms() do
        total_obtained_marks_of_subject =
          Enum.reduce(class.students, 0, fn student, acc ->
            related_subject = Enum.filter(student.subjects, fn student_subject ->
              student_subject.name == class_subject.name
            end) |> Enum.at(0)

            related_result = Enum.filter(related_subject.results, fn student_result ->
              student_result.name == result_name
            end) |> Enum.at(0)

            if (!is_nil(related_result.obtained_marks)) and (related_result.obtained_marks > 0) do
              related_result.obtained_marks + acc
            else
              acc
            end
          end)

        count_of_present_students =
          Enum.filter(class.students, fn class_student ->
            related_subject = Enum.filter(class_student.subjects, fn student_subject ->
              student_subject.name == class_subject.name
            end) |> Enum.at(0)

            related_result = Enum.filter(related_subject.results, fn student_result ->
              student_result.name == result_name
            end) |> Enum.at(0)

            !((is_nil(related_result.obtained_marks)) or (related_result.obtained_marks == 0))
          end) |> Enum.count()

        students_to_be_used =
          if count_of_present_students > 0, do: count_of_present_students, else: 1

        total_marks_of_subject =
          (Enum.filter(class_subject.results, fn class_result ->
            class_result.name == result_name
          end) |> Enum.at(0)).total_marks

        total_obtained_average = (total_obtained_marks_of_subject / students_to_be_used) |> round()

        result =
          Enum.filter(class_subject.results, fn student_result ->
            student_result.name == result_name
          end) |> Enum.at(0)

        update_result(result, %{"obtained_marks" => total_obtained_average, "total_marks" => total_marks_of_subject})
      end
    end
  end
end
