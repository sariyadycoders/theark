defmodule TheArk.Offdays do
  @moduledoc """
  The Offdays context.
  """

  import Ecto.Query, warn: false
  alias TheArk.Repo

  alias TheArk.Offdays.Offday

  @doc """
  Returns the list of offdays.

  ## Examples

      iex> list_offdays()
      [%Offday{}, ...]

  """
  def list_offdays do
    Repo.all(Offday)
  end

  @doc """
  Gets a single offday.

  Raises `Ecto.NoResultsError` if the Offday does not exist.

  ## Examples

      iex> get_offday!(123)
      %Offday{}

      iex> get_offday!(456)
      ** (Ecto.NoResultsError)

  """
  def get_offday!(id), do: Repo.get!(Offday, id)

  def get_offday_by_month_number(month_number, year) do
    Repo.one(
      from(
        od in Offday,
        where: od.month_number == ^month_number,
        where: od.year == ^year
      )
    )
  end

  @doc """
  Creates a offday.

  ## Examples

      iex> create_offday(%{field: value})
      {:ok, %Offday{}}

      iex> create_offday(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_offday(attrs \\ %{}) do
    %Offday{}
    |> Offday.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a offday.

  ## Examples

      iex> update_offday(offday, %{field: new_value})
      {:ok, %Offday{}}

      iex> update_offday(offday, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_offday(%Offday{} = offday, attrs) do
    offday
    |> Offday.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a offday.

  ## Examples

      iex> delete_offday(offday)
      {:ok, %Offday{}}

      iex> delete_offday(offday)
      {:error, %Ecto.Changeset{}}

  """
  def delete_offday(%Offday{} = offday) do
    Repo.delete(offday)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking offday changes.

  ## Examples

      iex> change_offday(offday)
      %Ecto.Changeset{data: %Offday{}}

  """
  def change_offday(%Offday{} = offday, attrs \\ %{}) do
    Offday.changeset(offday, attrs)
  end
end
