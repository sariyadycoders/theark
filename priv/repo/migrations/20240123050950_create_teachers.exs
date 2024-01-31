defmodule TheArk.Repo.Migrations.CreateTeachers do
  use Ecto.Migration

  def change do
    create table(:teachers) do
      add :name, :string
      add :date_of_joining, :date
      add :residence, :string
      add :date_of_leaving, :date

      timestamps(type: :utc_datetime)
    end
  end
end
