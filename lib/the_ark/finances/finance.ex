defmodule TheArk.Finances.Finance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "finances" do
    field :transaction_id, :string
    field :is_bill, :boolean, default: false
    field :absent_fine_date, :date
    field :absentee_name, :string

    has_many :transaction_details, TheArk.Transaction_details.Transaction_detail
    has_many :notes, TheArk.Notes.Note
    belongs_to :group, TheArk.Groups.Group
    belongs_to :teacher, TheArk.Teachers.Teacher

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(finance, attrs) do
    finance
    |> cast(attrs, [
      :transaction_id,
      :group_id,
      :teacher_id,
      :is_bill,
      :absent_fine_date,
      :absentee_name
    ])
    |> cast_assoc(:transaction_details,
      with: &TheArk.Transaction_details.Transaction_detail.changeset/2
    )
  end
end
