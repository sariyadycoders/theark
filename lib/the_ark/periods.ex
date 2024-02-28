defmodule TheArk.Periods do
  @moduledoc """
  The Periods context.
  """

  import Ecto.Query, warn: false
  alias TheArk.Subjects.Subject
  alias TheArk.Repo

  alias TheArk.Periods.Period

  @doc """
  Returns the list of periods.

  ## Examples

      iex> list_periods()
      [%Period{}, ...]

  """
  def list_periods do
    Repo.all(Period)
  end

  @doc """
  Gets a single period.

  Raises `Ecto.NoResultsError` if the period does not exist.

  ## Examples

      iex> get_period!(123)
      %Period{}

      iex> get_period!(456)
      ** (Ecto.NoResultsError)

  """
  def get_period!(id), do: Repo.get!(Period, id)

  def get_periods_by_number(number) do
    Repo.all(from(p in Period, where: p.period_number == ^number))
  end

  @doc """
  Creates a period.

  ## Examples

      iex> create_period(%{field: value})
      {:ok, %Period{}}

      iex> create_period(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_period(attrs \\ %{}) do
    %Period{}
    |> Period.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a period.

  ## Examples

      iex> update_period(period, %{field: new_value})
      {:ok, %Period{}}

      iex> update_period(period, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_period(%Period{} = period, attrs) do
    period
    |> Period.changeset(attrs)
    |> Repo.update()
  end

  def update_period_on_population(%Period{} = prev_period, attrs, class_id) do
    new_subject = Map.get(attrs, "subject")
    prev_subject = prev_period.subject

    if Enum.any?(
         Repo.all(from(p in Period, where: p.class_id == ^class_id and p.subject == ^new_subject))
       ) and !(new_subject == prev_subject) do
      Repo.update_all(
        from(p in Period, where: p.class_id == ^class_id and p.subject == ^new_subject),
        set: [teacher_id: nil, subject: nil]
      )
    end

    prev_period
    |> Period.changeset(attrs)
    |> Repo.update()
    |> update_subjects_teacher_id(prev_period, attrs, class_id)
  end

  def update_subjects_teacher_id({:ok, new_preriod}, prev_period, attrs, class_id) do
    prev_subject = prev_period.subject
    new_subject = Map.get(attrs, "subject")
    teacher_id = Map.get(attrs, "teacher_id") |> String.to_integer()

    if prev_subject && !(new_subject == prev_subject) do
      Repo.update_all(
        from(s in Subject, where: s.class_id == ^class_id and s.name == ^prev_subject),
        set: [teacher_id: nil]
      )
    end

    Repo.update_all(from(s in Subject, where: s.class_id == ^class_id and s.name == ^new_subject),
      set: [teacher_id: teacher_id]
    )

    {:ok, new_preriod}
  end

  def update_subjects_teacher_id({:error, _new_preriod} = error, _prev_period, _attrs, _class_id) do
    error
  end

  @doc """
  Deletes a period.

  ## Examples

      iex> delete_period(period)
      {:ok, %Period{}}

      iex> delete_period(period)
      {:error, %Ecto.Changeset{}}

  """
  def delete_period(%Period{} = period) do
    Repo.delete(period)
  end

  def delete_all_periods() do
    TheArk.Repo.delete_all(TheArk.Periods.Period)
  end

  def delete_periods_with_period_numbers(list_of_numbers) do
    periods = Repo.all(from(p in Period, where: p.period_number in ^list_of_numbers))

    for period <- periods do
      delete_period(period)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking period changes.

  ## Examples

      iex> change_period(period)
      %Ecto.Changeset{data: %Period{}}

  """
  def change_period(%Period{} = period, attrs \\ %{}) do
    Period.changeset(period, attrs)
  end
end
