defmodule TheArk.Subjects do
  @moduledoc """
  The Subjects context.
  """

  import Ecto.Query, warn: false
  alias TheArk.Repo

  alias TheArk.Subjects.Subject
  # alias TheArk.Results.Result
  # alias TheArk.Results

  @doc """
  Returns the list of subjects.

  ## Examples

      iex> list_subjects()
      [%Subject{}, ...]

  """
  def list_subjects do
    Repo.all(Subject)
  end

  def list_subject_options do
    Repo.all(
      from s in Subject,
        where: is_nil(s.class_id) and is_nil(s.student_id),
        select: %{id: s.id, label: s.name, selected: false}
    )
  end

  @doc """
  Gets a single subject.

  Raises `Ecto.NoResultsError` if the Subject does not exist.

  ## Examples

      iex> get_subject!(123)
      %Subject{}

      iex> get_subject!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subject!(id), do: Repo.get!(Subject, id) |> Repo.preload(:results)

  def get_subject_for_result_edition(student, subject_name) do
    Repo.one(from s in Subject, where: s.student_id == ^student.id and s.name == ^subject_name)
  end

  def get_subject_name_by_subject_id(class_id, subject_id) do
    Repo.one(
      from s in Subject,
        where:
          s.is_class_subject == true and s.class_id == ^class_id and s.subject_id == ^subject_id,
        select: s.name
    )
  end

  def get_subject_by_subject_id(class_id, subject_id) do
    Repo.one(
      from s in Subject,
        where:
          s.is_class_subject == true and s.class_id == ^class_id and s.subject_id == ^subject_id,
        preload: :results
    )
  end

  def get_subjects_of_class(class_id) do
    Repo.all(
      from s in Subject,
        where: s.is_class_subject == true and s.class_id == ^class_id,
        select: %{id: s.subject_id, label: s.name}
    )
  end

  def get_subjects_for_student(class_id) do
    Repo.all(
      from s in Subject,
        where: s.is_class_subject == true and s.class_id == ^class_id,
        select: %{id: s.subject_id, label: s.name, teacher_id: s.teacher_id}
    )
  end

  def get_subjects_of_teacher_for_class(class_id, teacher_id) do
    Repo.all(
      from s in Subject,
        where:
          s.is_class_subject == true and s.teacher_id == ^teacher_id and s.class_id == ^class_id
    )
  end

  @doc """
  Creates a subject.

  ## Examples

      iex> create_subject(%{field: value})
      {:ok, %Subject{}}

      iex> create_subject(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subject(attrs \\ %{}) do
    %Subject{}
    |> Subject.changeset(attrs)
    |> Repo.insert()
    |> create_results()
  end

  def create_results({:ok, subject}) do
    for name <- ["first_term", "second_term", "third_term"] do
      TheArk.Results.create_result(%{"name" => name, "subject_id" => subject.id})
    end

    {:ok, subject}
  end

  def create_results({:error, _} = error) do
    error
  end

  @doc """
  Updates a subject.

  ## Examples

      iex> update_subject(subject, %{field: new_value})
      {:ok, %Subject{}}

      iex> update_subject(subject, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subject(%Subject{} = subject, attrs) do
    subject
    |> Subject.changeset(attrs)
    |> Repo.update()
  end

  def replace_teacher_id_of_subjects(prev_id, new_id) do
    Repo.update_all(from(s in Subject, where: s.teacher_id == ^prev_id), set: [teacher_id: new_id])
  end

  def replace_class_id_of_subjects(prev_id, new_id) do
    Repo.update_all(from(s in Subject, where: s.class_id == ^prev_id), set: [class_id: new_id])
  end

  def assign_subjects_to_teacher(subject_options, class_id, teacher_id) do
    prev_subject_ids_of_teacher_for_class =
      get_subjects_of_teacher_for_class(class_id, teacher_id)
      |> Enum.map(fn subject -> subject.subject_id end)

    new_subject_ids =
      Enum.filter(subject_options, fn subject -> subject.selected end)
      |> Enum.map(fn subject -> subject.id end)

    new_subjects = Enum.filter(subject_options, fn subject -> subject.selected end)

    subject_ids_to_delete =
      Enum.filter(prev_subject_ids_of_teacher_for_class, fn id ->
        id not in new_subject_ids
      end)

    deleted_subjects =
      Enum.filter(subject_options, fn subject ->
        subject.id in subject_ids_to_delete
      end)

    for subject <- deleted_subjects do
      Repo.update_all(
        from(s in Subject, where: s.name == ^subject.label and s.class_id == ^class_id),
        set: [teacher_id: nil]
      )
    end

    for subject <- new_subjects do
      Repo.update_all(
        from(s in Subject, where: s.name == ^subject.label and s.class_id == ^class_id),
        set: [teacher_id: teacher_id]
      )
    end
  end

  @doc """
  Deletes a subject.

  ## Examples

      iex> delete_subject(subject)
      {:ok, %Subject{}}

      iex> delete_subject(subject)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subject(%Subject{} = subject) do
    Repo.delete(subject)
  end

  def delete_subject_by_id(id) do
    subject = get_subject!(id)
    delete_subject(subject)
  end

  def delete_all_by_attributes(attributes) do
    Repo.delete_all(from(s in Subject, where: ^attributes))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subject changes.

  ## Examples

      iex> change_subject(subject)
      %Ecto.Changeset{data: %Subject{}}

  """
  def change_subject(%Subject{} = subject, attrs \\ %{}) do
    Subject.changeset(subject, attrs)
  end
end
