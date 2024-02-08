defmodule TheArk.Slos.Slo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "slos" do
    field :description, :string
    belongs_to :class, TheArk.Classes.Class

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(slo, attrs) do
    slo
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end
end
