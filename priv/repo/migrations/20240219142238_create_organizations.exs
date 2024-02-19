defmodule TheArk.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string
      add :number_of_students, :integer
      add :number_of_staff, :integer
      add :number_of_years, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
