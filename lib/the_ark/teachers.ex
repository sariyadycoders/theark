defmodule TheArk.Teachers do
  @moduledoc """
  The Teachers context.
  """

  import Ecto.Query, warn: false
  alias TheArk.Repo

  alias TheArk.Teachers.Teacher
  alias TheArk.Subjects.Subject

  @doc """
  Returns the list of teachers.

  ## Examples

      iex> list_teachers()
      [%Teacher{}, ...]

  """
  def list_teachers do
    Repo.all(from(t in Teacher, order_by: t.id))
    |> Repo.preload(subjects: from(s in Subject, where: s.is_class_subject == true))
    |> Repo.preload(subjects: :class)
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
    |> Repo.preload(subjects: from(s in Subject, where: s.is_class_subject == true))
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
