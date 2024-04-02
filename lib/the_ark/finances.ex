defmodule TheArk.Finances do
  @moduledoc """
  The Finances context.
  """

  import Ecto.Query, warn: false
  alias TheArk.Repo

  alias TheArk.Finances.Finance
  alias TheArk.Transaction_details.Transaction_detail
  alias TheArk.Notes.Note

  @doc """
  Returns the list of finances.

  ## Examples

      iex> list_finances()
      [%Finance{}, ...]

  """
  def list_finances do
    Repo.all(Finance)
  end

  def get_finances_for_group(group_id, title, type, order, t_id) do
    date_order = if order == "asc", do: [asc: :inserted_at], else: [desc: :inserted_at]

    detail_conditions =
      if title == "All" and type == "All" do
        []
      else
        if title == "All" and type != "All" do
          if type == "Only Due" do
            dynamic([d], d.due_amount > 0)
          else
            dynamic([d], d.paid_amount == d.total_amount)
          end
        else
          if title != "All" and type == "All" do
            dynamic([d], d.title == ^title)
          else
            if title != "All" and type == "Only Due" do
              dynamic([d], d.title == ^title and d.due_amount > 0)
            else
              dynamic([d], d.title == ^title and d.paid_amount == d.total_amount)
            end
          end
        end
      end

    Repo.all(
      from(f in Finance,
        where: f.group_id == ^group_id and ilike(f.transaction_id, ^"%#{t_id}%"),
        order_by: ^date_order
      )
    )
    |> Repo.preload(
      transaction_details: from(d in Transaction_detail, where: ^detail_conditions),
      notes: from(n in Note, order_by: [desc: n.updated_at])
    )
    |> Enum.reject(fn finance ->
      Enum.count(finance.transaction_details) == 0
    end)
  end

  @doc """
  Gets a single finance.

  Raises `Ecto.NoResultsError` if the Finance does not exist.

  ## Examples

      iex> get_finance!(123)
      %Finance{}

      iex> get_finance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_finance!(id) do
    Repo.get!(Finance, id)
    |> Repo.preload(:transaction_details)
  end

  def get_finance_for_reciept(id) do
    Repo.get!(Finance, id)
    |> Repo.preload(:transaction_details)
    |> Repo.preload(group: [students: :class])
  end

  @doc """
  Creates a finance.

  ## Examples

      iex> create_finance(%{field: value})
      {:ok, %Finance{}}

      iex> create_finance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_finance(changeset) do
    Repo.insert_or_update(changeset)
  end

  @doc """
  Updates a finance.

  ## Examples

      iex> update_finance(finance, %{field: new_value})
      {:ok, %Finance{}}

      iex> update_finance(finance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_finance(%Finance{} = finance, attrs) do
    finance
    |> Finance.changeset(attrs)
    |> Repo.update()
  end

  def update_finance(changeset) do
    Repo.update(changeset)
  end

  @doc """
  Deletes a finance.

  ## Examples

      iex> delete_finance(finance)
      {:ok, %Finance{}}

      iex> delete_finance(finance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_finance(%Finance{} = finance) do
    Repo.delete(finance)
  end

  def delete_finance_by_id(id) do
    finance = get_finance!(id)
    delete_finance(finance)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking finance changes.

  ## Examples

      iex> change_finance(finance)
      %Ecto.Changeset{data: %Finance{}}

  """
  def change_finance(%Finance{} = finance, attrs \\ %{}) do
    Finance.changeset(finance, attrs)
  end
end
