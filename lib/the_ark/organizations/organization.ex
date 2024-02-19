defmodule TheArk.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field :name, :string
    field :number_of_staff, :integer
    field :number_of_students, :integer
    field :number_of_years, :integer

    has_many :roles, TheArk.Roles.Role, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :number_of_students, :number_of_staff, :number_of_years])
    |> validate_required([:name, :number_of_students, :number_of_staff, :number_of_years])
  end
end
