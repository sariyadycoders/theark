defmodule TheArk.Finances.Finance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "finances" do
    field :transaction_id, :string
    field :is_bill, :boolean, default: :false

    has_many :transaction_details, TheArk.Transaction_details.Transaction_detail
    belongs_to :student, TheArk.Students.Student

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(finance, attrs) do
    finance
    |> cast(attrs, [:transaction_id, :student_id])
    |> validate_required([:student_id])
  end
end
