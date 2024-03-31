defmodule TheArk.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string
    field :monthly_fee, :integer
    field :is_main, :boolean
    has_many :students, TheArk.Students.Student, on_delete: :nothing
    has_many :finances, TheArk.Finances.Finance, on_delete: :nothing

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :monthly_fee, :is_main])
    |> validate_required([:name])
  end
end
