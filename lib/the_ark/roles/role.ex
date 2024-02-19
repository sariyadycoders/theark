defmodule TheArk.Roles.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :contact_number, :string
    field :name, :string
    field :role, :string

    belongs_to :organization, TheArk.Organizations.Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :contact_number, :role])
    |> validate_required([:name, :contact_number, :role])
  end
end
