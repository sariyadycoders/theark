defmodule TheArk.Students do
  @moduledoc """
  The Students context.
  """

  import Ecto.Query, warn: false
  alias TheArk.Repo
  alias TheArk.Subjects

  alias TheArk.Students.Student

  @doc """
  Returns the list of students.

  ## Examples

      iex> list_students()
      [%Student{}, ...]

  """
  def list_students do
    Repo.all(Student)
  end

  def list_students_for_index() do
    Repo.all(
      from s in Student,
      order_by: s.class_id,
      preload: :class
    )
  end

  @doc """
  Gets a single student.

  Raises `Ecto.NoResultsError` if the Student does not exist.

  ## Examples

      iex> get_student!(123)
      %Student{}

      iex> get_student!(456)
      ** (Ecto.NoResultsError)

  """
  def get_student!(id) do
     Repo.get!(Student, id)
     |> Repo.preload(subjects: [:results])
  end

  def get_students_by_class_id(id) do
    Repo.all(from(s in Student, where: s.class_id == ^id))
    |> Repo.preload(subjects: [:results])
  end

  @doc """
  Creates a student.

  ## Examples

      iex> create_student(%{field: value})
      {:ok, %Student{}}

      iex> create_student(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_student(attrs \\ %{}) do
    %Student{}
    |> Student.changeset(attrs)
    |> Repo.insert()
    |> create_subjects()
  end

  def create_subjects({:ok, student}) do
    for %{id: subject_id, label: name, teacher_id: teacher_id} <- Subjects.get_subjects_for_student(student.class_id) do
      TheArk.Subjects.create_subject(%{"name" => name, "class_id" => student.class_id, "student_id" => student.id, "subject_id" => subject_id, "teacher_id" => teacher_id})
    end

    {:ok, student}
  end

  def create_subjects({:error, _changeset} = error) do
    error
  end

  @doc """
  Updates a student.

  ## Examples

      iex> update_student(student, %{field: new_value})
      {:ok, %Student{}}

      iex> update_student(student, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_student(%Student{} = student, attrs) do
    student
    |> Student.changeset(attrs)
    |> Repo.update()
  end

  def replace_class_id_of_students(prev_id, new_id) do
    Repo.update_all(from(s in Student, where: s.class_id == ^prev_id), set: [class_id: new_id])
  end

  def replace_subjects_of_students(new_class_id) do
    students = get_students_by_class_id(new_class_id)

    for student <- students do
      Subjects.delete_all_by_attributes([student_id: student.id])
      create_subjects({:ok, student})
    end
  end

  @doc """
  Deletes a student.

  ## Examples

      iex> delete_student(student)
      {:ok, %Student{}}

      iex> delete_student(student)
      {:error, %Ecto.Changeset{}}

  """
  def delete_student(%Student{} = student) do
    Repo.delete(student)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking student changes.

  ## Examples

      iex> change_student(student)
      %Ecto.Changeset{data: %Student{}}

  """
  def change_student(%Student{} = student, attrs \\ %{}) do
    Student.changeset(student, attrs)
  end
end
