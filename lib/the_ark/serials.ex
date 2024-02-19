defmodule TheArk.Serials do
  @moduledoc """
  The Serials context.
  """

  import Ecto.Query, warn: false
  alias TheArk.Repo

  alias TheArk.Serials.Serial

  @doc """
  Returns the list of serials.

  ## Examples

      iex> list_serials()
      [%Serial{}, ...]

  """
  def list_serials do
    Repo.all(Serial)
  end

  @doc """
  Gets a single serial.

  Raises `Ecto.NoResultsError` if the Serial does not exist.

  ## Examples

      iex> get_serial!(123)
      %Serial{}

      iex> get_serial!(456)
      ** (Ecto.NoResultsError)

  """
  def get_serial!(id), do: Repo.get!(Serial, id)

  def get_serial_by_name(name) do
    Repo.get_by(Serial, name: name)
  end

  @doc """
  Creates a serial.

  ## Examples

      iex> create_serial(%{field: value})
      {:ok, %Serial{}}

      iex> create_serial(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_serial(attrs \\ %{}) do
    %Serial{}
    |> Serial.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a serial.

  ## Examples

      iex> update_serial(serial, %{field: new_value})
      {:ok, %Serial{}}

      iex> update_serial(serial, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_serial(%Serial{} = serial, attrs) do
    serial
    |> Serial.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a serial.

  ## Examples

      iex> delete_serial(serial)
      {:ok, %Serial{}}

      iex> delete_serial(serial)
      {:error, %Ecto.Changeset{}}

  """
  def delete_serial(%Serial{} = serial) do
    Repo.delete(serial)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking serial changes.

  ## Examples

      iex> change_serial(serial)
      %Ecto.Changeset{data: %Serial{}}

  """
  def change_serial(%Serial{} = serial, attrs \\ %{}) do
    Serial.changeset(serial, attrs)
  end
end
