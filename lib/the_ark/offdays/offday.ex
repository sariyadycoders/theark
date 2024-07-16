defmodule TheArk.Offdays.Offday do
  use Ecto.Schema
  import Ecto.Changeset

  schema "offdays" do
    field :month_number, :integer
    field :year, :integer
    field :days, {:array, :integer}
    field :for_staff, :boolean
    field :for_students, :boolean

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(offday, attrs) do
    offday
    |> cast(attrs, [:month_number, :year, :days, :for_staff, :for_students])
    |> validate_required([:month_number, :year, :days, :for_staff, :for_students])
  end
end
