defmodule TheArk.Classresults do
  @moduledoc """
  The Classresults context.
  """

  import Ecto.Query, warn: false
  alias TheArk.Repo

  alias TheArk.Classresults.Classresult
  alias TheArk.Classes

  @doc """
  Returns the list of classresults.

  ## Examples

      iex> list_classresults()
      [%Classresult{}, ...]

  """
  def list_classresults do
    Repo.all(Classresult)
  end

  @doc """
  Gets a single classresult.

  Raises `Ecto.NoResultsError` if the Classresult does not exist.

  ## Examples

      iex> get_classresult!(123)
      %Classresult{}

      iex> get_classresult!(456)
      ** (Ecto.NoResultsError)

  """
  def get_classresult!(id), do: Repo.get!(Classresult, id)

  @doc """
  Creates a classresult.

  ## Examples

      iex> create_classresult(%{field: value})
      {:ok, %Classresult{}}

      iex> create_classresult(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_classresult(attrs \\ %{}) do
    %Classresult{}
    |> Classresult.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a classresult.

  ## Examples

      iex> update_classresult(classresult, %{field: new_value})
      {:ok, %Classresult{}}

      iex> update_classresult(classresult, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_classresult(%Classresult{} = classresult, attrs) do
    classresult
    |> Classresult.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a classresult.

  ## Examples

      iex> delete_classresult(classresult)
      {:ok, %Classresult{}}

      iex> delete_classresult(classresult)
      {:error, %Ecto.Changeset{}}

  """
  def delete_classresult(%Classresult{} = classresult) do
    Repo.delete(classresult)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking classresult changes.

  ## Examples

      iex> change_classresult(classresult)
      %Ecto.Changeset{data: %Classresult{}}

  """
  def change_classresult(%Classresult{} = classresult, attrs \\ %{}) do
    Classresult.changeset(classresult, attrs)
  end

  def prepare_class_results(id) do
    class = Classes.get_class!(id)

    for class_subject <- class.subjects do
      for result_name <- Classes.make_list_of_terms() do
        total_obtained_marks_of_subject =
          Enum.reduce(class.students, 0, fn student, acc ->
            related_subject =
              Enum.filter(student.subjects, fn student_subject ->
                student_subject.name == class_subject.name
              end)
              |> Enum.at(0)

            related_result =
              Enum.filter(related_subject.results, fn student_result ->
                student_result.name == result_name
              end)
              |> Enum.at(0)

            if !is_nil(related_result.obtained_marks) and related_result.obtained_marks > 0 do
              related_result.obtained_marks + acc
            else
              acc
            end
          end)

        count_of_present_students =
          Enum.filter(class.students, fn class_student ->
            related_subject =
              Enum.filter(class_student.subjects, fn student_subject ->
                student_subject.name == class_subject.name
              end)
              |> Enum.at(0)

            related_result =
              Enum.filter(related_subject.results, fn student_result ->
                student_result.name == result_name
              end)
              |> Enum.at(0)

            !(is_nil(related_result.obtained_marks) or related_result.obtained_marks == 0)
          end)
          |> Enum.count()

        absent_students =
          Enum.filter(class.students, fn class_student ->
            related_subject =
              Enum.filter(class_student.subjects, fn student_subject ->
                student_subject.name == class_subject.name
              end)
              |> Enum.at(0)

            related_result =
              Enum.filter(related_subject.results, fn student_result ->
                student_result.name == result_name
              end)
              |> Enum.at(0)

            is_nil(related_result.obtained_marks) or related_result.obtained_marks == 0
          end)
          |> Enum.map(fn student ->
            student.name
          end)

        students_to_be_used =
          if count_of_present_students > 0, do: count_of_present_students, else: 1

        total_marks_of_subject =
          (Enum.filter(class_subject.classresults, fn class_result ->
             class_result.name == result_name
           end)
           |> Enum.at(0)).total_marks

        total_obtained_average =
          (total_obtained_marks_of_subject / students_to_be_used) |> round()

        result =
          Enum.filter(class_subject.classresults, fn student_result ->
            student_result.name == result_name
          end)
          |> Enum.at(0)

        update_classresult(result, %{
          "obtained_marks" => total_obtained_average,
          "total_marks" => total_marks_of_subject,
          "students_appeared" => count_of_present_students,
          "absent_students" => absent_students
        })
      end
    end
  end
end
