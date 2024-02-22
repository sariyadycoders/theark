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
    |> cast(attrs, [:name, :contact_number, :role, :organization_id])
    |> validate_required([:name, :contact_number, :role])
    |> validate_format(:contact_number, ~r/^03\d{9}$/,
      message: "must start with 03 and have exactly 11 numbers"
    )
  end
end
