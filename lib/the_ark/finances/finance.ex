defmodule TheArk.Finances.Finance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "finances" do
    field :transaction_id, :string
    field :is_bill, :boolean, default: false
    # field :student_id, :integer

    has_many :transaction_details, TheArk.Transaction_details.Transaction_detail
    belongs_to :group, TheArk.Groups.Group

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(finance, attrs) do
    finance
    |> cast(attrs, [:transaction_id, :group_id])
    |> cast_assoc(:transaction_details,
      with: &TheArk.Transaction_details.Transaction_detail.changeset/2
    )
    |> validate_required([:student_id])
  end
end
