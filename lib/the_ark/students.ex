defmodule TheArk.Students do
  @moduledoc """
  The Students context.
  """

  import Ecto.Query, warn: false

  alias TheArk.Repo
  alias TheArk.Subjects
  alias TheArk.Subjects.Subject
  alias TheArk.Groups
  alias TheArk.Notes.Note

  alias TheArk.Students.Student
  alias TheArk.Attendances

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
        order_by: s.is_leaving,
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
    |> Repo.preload([
      [subjects: from(s in Subject, order_by: s.subject_id, preload: :results)],
      [notes: from(n in Note, order_by: [desc: n.updated_at])],
      :class
    ])
  end

  def get_student_for_finance(id) do
    Repo.get!(Student, id)
    |> Repo.preload(:class)
  end

  def get_student_only(id) do
    Repo.get!(Student, id)
  end

  def get_students_by_class_id(id) do
    Repo.all(from(s in Student, where: s.class_id == ^id))
    |> Repo.preload(subjects: [:results])
  end

  def get_student_options_for_attendance(id) do
    Repo.all(
      from(s in Student,
        where: s.class_id == ^id,
        select: %{id: s.id, label: s.name, selected: false}
      )
    )
  end

  def get_students_for_search_results(name) do
    Repo.all(from(s in Student, where: ilike(s.name, ^"%#{name}%")))
    |> Repo.preload(:class)
  end

  def get_active_students_count() do
    Repo.aggregate(from(s in Student, where: s.is_leaving == false), :count)
  end

  def get_students_count() do
    Repo.aggregate(from(s in Student), :count)
  end

  def get_student_name(id) do
    Repo.one(from(s in Student, where: s.id == ^id, select: s.name))
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
    |> create_group()
    |> create_attendance_of_month()
  end

  def create_attendance_of_month({:ok, student}) do
    for day_number <- 1..Timex.days_in_month(Timex.today()) do
      beginning_of_month = Timex.beginning_of_month(Timex.today())
      date = Date.add(beginning_of_month, day_number - 1)
      entry = "Not Marked Yet"

      Attendances.create_attendance(%{date: date, entry: entry, student_id: student.id})
    end

    {:ok, student}
  end

  def create_attendance_of_month({:error, _} = error) do
    error
  end

  def create_group({:ok, student}) do
    {:ok, group} = Groups.create_group(%{name: student.name, is_main: false})
    {:ok, student} = update_student(student, %{group_id: group.id, first_group_id: group.id})

    {:ok, student}
  end

  def create_group({:error, _changeset} = error) do
    error
  end

  def create_subjects({:ok, student}) do
    for %{id: subject_id, label: name, teacher_id: teacher_id} <-
          Subjects.get_subjects_for_student(student.class_id) do
      TheArk.Subjects.create_subject(%{
        "name" => name,
        "class_id" => student.class_id,
        "student_id" => student.id,
        "subject_id" => subject_id,
        "teacher_id" => teacher_id
      })
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

  def update_student_leaving(%Student{} = student, attrs) do
    student
    |> Student.leaving_changeset(attrs)
    |> Repo.update()
  end

  def reactivate_student(id) do
    Repo.update_all(from(s in Student, where: s.id == ^id),
      set: [
        is_leaving: false,
        leaving_class: nil,
        leaving_certificate_date: nil,
        last_attendance_date: nil
      ]
    )
  end

  def replace_class_id_of_students(prev_id, new_id) do
    Repo.update_all(from(s in Student, where: s.class_id == ^prev_id), set: [class_id: new_id])
  end

  def replace_subjects_of_students(new_class_id) do
    students = get_students_by_class_id(new_class_id)

    for student <- students do
      Subjects.delete_all_by_attributes(student_id: student.id)
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

  def change_student_leaving(%Student{} = student, attrs \\ %{}) do
    Student.leaving_changeset(student, attrs)
  end
end
