defmodule TheArk.Transaction_details do
  @moduledoc """
  The Transaction_details context.
  """

  import Ecto.Query, warn: false

  alias TheArk.Students
  alias TheArk.Groups.Group
  alias TheArk.Finances.Finance
  alias TheArk.Shared
  alias TheArk.Repo
  alias TheArk.Transaction_details.Transaction_detail

  @doc """
  Returns the list of transaction_details.

  ## Examples

      iex> list_transaction_details()
      [%Transaction_detail{}, ...]

  """
  def list_transaction_details do
    Repo.all(Transaction_detail)
  end

  def get_absentee_due_students_for_submission(class_id, month) do
    list_of_date = Shared.list_of_dates(month)
    student_ids_of_class = Students.get_all_active_students_ids(class_id)

    from(
      t in Transaction_detail,
      join: f in Finance,
      on: t.finance_id == f.id,
      join: g in Group,
      on: f.group_id == g.id,
      where: f.absent_fine_date in ^list_of_date,
      where: t.title == "Absent Fine",
      where: t.paid_amount == 0,
      select: %{
        name: f.absent_student_name,
        date: f.absent_fine_date,
        transaction_id: t.id,
        group_id: g.id
      }
    )
    |> Repo.all()
    |> Enum.filter(fn record ->
      student_ids_of_group = Students.get_all_active_students_ids_of_group(record.group_id)

      Enum.any?(student_ids_of_group, fn id -> id in student_ids_of_class end)
    end)
    |> Enum.map(fn record ->
      Map.delete(record, :group_id)
    end)
  end

  @doc """
  Gets a single transaction_detail.

  Raises `Ecto.NoResultsError` if the Transaction detail does not exist.

  ## Examples

      iex> get_transaction_detail!(123)
      %Transaction_detail{}

      iex> get_transaction_detail!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction_detail!(id), do: Repo.get!(Transaction_detail, id)

  @doc """
  Creates a transaction_detail.

  ## Examples

      iex> create_transaction_detail(%{field: value})
      {:ok, %Transaction_detail{}}

      iex> create_transaction_detail(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction_detail(attrs \\ %{}) do
    %Transaction_detail{}
    |> Transaction_detail.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction_detail.

  ## Examples

      iex> update_transaction_detail(transaction_detail, %{field: new_value})
      {:ok, %Transaction_detail{}}

      iex> update_transaction_detail(transaction_detail, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction_detail(%Transaction_detail{} = transaction_detail, attrs) do
    transaction_detail
    |> Transaction_detail.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction_detail.

  ## Examples

      iex> delete_transaction_detail(transaction_detail)
      {:ok, %Transaction_detail{}}

      iex> delete_transaction_detail(transaction_detail)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction_detail(%Transaction_detail{} = transaction_detail) do
    Repo.delete(transaction_detail)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction_detail changes.

  ## Examples

      iex> change_transaction_detail(transaction_detail)
      %Ecto.Changeset{data: %Transaction_detail{}}

  """
  def change_transaction_detail(%Transaction_detail{} = transaction_detail, attrs \\ %{}) do
    Transaction_detail.changeset(transaction_detail, attrs)
  end
end
