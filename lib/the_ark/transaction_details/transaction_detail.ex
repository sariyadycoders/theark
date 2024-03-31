defmodule TheArk.Transaction_details.Transaction_detail do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transaction_details" do
    field :title, :string
    field :month, :string
    field :total_amount, :integer
    field :paid_amount, :integer
    field :due_amount, :integer
    field :is_accected, :boolean

    belongs_to :finance, TheArk.Finances.Finance

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction_detail, attrs) do
    transaction_detail
    |> cast(attrs, [:title, :total_amount, :paid_amount, :finance_id, :is_accected, :month])
    |> calculate_due_amount()
    |> validate_required([:title, :total_amount, :paid_amount])
  end

  def calculate_due_amount(changeset) do
    total_amount = get_field(changeset, :total_amount)
    paid_amount = get_field(changeset, :paid_amount)

    if total_amount && paid_amount do
      due_amount = total_amount - paid_amount
      put_change(changeset, :due_amount, due_amount)
    else
      changeset
    end
  end
end
