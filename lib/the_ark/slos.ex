defmodule TheArk.Slos do
  @moduledoc """
  The Slos context.
  """

  import Ecto.Query, warn: false
  alias TheArk.Repo

  alias TheArk.Slos.Slo

  @doc """
  Returns the list of slos.

  ## Examples

      iex> list_slos()
      [%Slo{}, ...]

  """
  def list_slos do
    Repo.all(Slo)
  end

  @doc """
  Gets a single slo.

  Raises `Ecto.NoResultsError` if the Slo does not exist.

  ## Examples

      iex> get_slo!(123)
      %Slo{}

      iex> get_slo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_slo!(id), do: Repo.get!(Slo, id)

  @doc """
  Creates a slo.

  ## Examples

      iex> create_slo(%{field: value})
      {:ok, %Slo{}}

      iex> create_slo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_slo(attrs \\ %{}) do
    %Slo{}
    |> Slo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a slo.

  ## Examples

      iex> update_slo(slo, %{field: new_value})
      {:ok, %Slo{}}

      iex> update_slo(slo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_slo(%Slo{} = slo, attrs) do
    slo
    |> Slo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a slo.

  ## Examples

      iex> delete_slo(slo)
      {:ok, %Slo{}}

      iex> delete_slo(slo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_slo(%Slo{} = slo) do
    Repo.delete(slo)
  end

  def delete_slo_by_id(id) do
    slo = get_slo!(id)
    delete_slo(slo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking slo changes.

  ## Examples

      iex> change_slo(slo)
      %Ecto.Changeset{data: %Slo{}}

  """
  def change_slo(%Slo{} = slo, attrs \\ %{}) do
    Slo.changeset(slo, attrs)
  end
end
