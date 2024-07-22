defmodule TheArk.Repo.Migrations.CreateOffdays do
  use Ecto.Migration

  def change do
    create table(:offdays) do
      add :month_number, :integer
      add :year, :integer
      add :days, {:array, :integer}
      add :for_staff, :boolean
      add :for_students, :boolean

      timestamps(type: :utc_datetime)
    end
  end
end
