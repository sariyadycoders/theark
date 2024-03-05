defmodule TheArk.Transaction_details.Transaction_detail do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transaction_details" do
    field :title, :string
    field :total_amount, :integer
    field :paid_amount, :integer
    field :due_amount, :integer

    belongs_to :finance, TheArk.Finances.Finance

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction_detail, attrs) do
    transaction_detail
    |> cast(attrs, [:title, :total_amount, :paid_amount, :due_amount, :finance_id])
    |> validate_required([:title, :total_amount, :paid_amount, :due_amount, :finance_id])
  end
end
