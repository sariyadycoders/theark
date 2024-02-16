defmodule TheArk.Serials.Serial do
  use Ecto.Schema
  import Ecto.Changeset

  schema "serials" do
    field :name, :string
    field :number, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(serial, attrs) do
    serial
    |> cast(attrs, [:name, :number])
    |> validate_required([:name, :number])
  end
end
