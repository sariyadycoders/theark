defmodule TheArk.Teachers do
  @moduledoc """
  The Teachers context.
  """

  import Ecto.Query, warn: false
  alias TheArk.Repo

  alias TheArk.Teachers.Teacher
  alias TheArk.Subjects.Subject
  alias TheArk.Periods.Period
  alias TheArk.Attendances

  @doc """
  Returns the list of teachers.

  ## Examples

      iex> list_teachers()
      [%Teacher{}, ...]

  """
  def list_teachers do
    Repo.all(from(t in Teacher, order_by: t.is_leaving, order_by: t.id))
    |> Repo.preload(subjects: from(s in Subject, where: s.is_class_subject == true))
    |> Repo.preload(subjects: :class)
    |> Repo.preload(periods: from(p in Period, order_by: p.period_number, preload: :class))
  end

  @doc """
  Gets a single teacher.

  Raises `Ecto.NoResultsError` if the Teacher does not exist.

  ## Examples

      iex> get_teacher!(123)
      %Teacher{}

      iex> get_teacher!(456)
      ** (Ecto.NoResultsError)

  """
  def get_teacher!(id) do
    Repo.get!(Teacher, id)
  end

  def get_teacher_for_collective_result!(id) do
    Repo.get!(Teacher, id)
    |> Repo.preload(
      subjects:
        from(s in Subject, where: s.is_class_subject == true, preload: [:classresults, :class])
    )
  end

  def get_teacher_for_result!(id) do
    Repo.get!(Teacher, id)
    |> Repo.preload(
      subjects: from(s in Subject, where: s.is_class_subject == false, order_by: s.class_id)
    )
  end

  def get_teacher_options() do
    Repo.all(from(t in Teacher, select: %{name: t.name, id: t.id}))
    |> Enum.flat_map(fn teacher ->
      ["#{teacher.name}": teacher.id]
    end)
  end

  @doc """
  Creates a teacher.

  ## Examples

      iex> create_teacher(%{field: value})
      {:ok, %Teacher{}}

      iex> create_teacher(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_teacher(attrs \\ %{}) do
    %Teacher{}
    |> Teacher.changeset(attrs)
    |> Repo.insert()
    |> create_attendance_of_month()
  end

  def create_attendance_of_month({:ok, teacher}) do
    for day_number <- 1..Timex.days_in_month(Timex.today()) do
      beginning_of_month = Timex.beginning_of_month(Timex.today())
      date = Date.add(beginning_of_month, day_number - 1)
      entry = "Not Marked Yet"

      Attendances.create_attendance(%{date: date, entry: entry, teacher_id: teacher.id})
    end

    {:ok, teacher}
  end

  def create_attendance_of_month({:error, _} = error) do
    error
  end

  @doc """
  Updates a teacher.

  ## Examples

      iex> update_teacher(teacher, %{field: new_value})
      {:ok, %Teacher{}}

      iex> update_teacher(teacher, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_teacher(%Teacher{} = teacher, attrs) do
    teacher
    |> Teacher.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a teacher.

  ## Examples

      iex> delete_teacher(teacher)
      {:ok, %Teacher{}}

      iex> delete_teacher(teacher)
      {:error, %Ecto.Changeset{}}

  """
  def delete_teacher(%Teacher{} = teacher) do
    Repo.delete(teacher)
  end

  def delete_teacher_by_id(id) do
    teacher = get_teacher!(id)
    delete_teacher(teacher)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking teacher changes.

  ## Examples

      iex> change_teacher(teacher)
      %Ecto.Changeset{data: %Teacher{}}

  """
  def change_teacher(%Teacher{} = teacher, attrs \\ %{}) do
    Teacher.changeset(teacher, attrs)
  end
end
