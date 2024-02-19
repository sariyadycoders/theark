defmodule TheArk.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :name, :string
      add :contact_number, :string
      add :role, :string
      add :organization_id, references(:organizations, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
