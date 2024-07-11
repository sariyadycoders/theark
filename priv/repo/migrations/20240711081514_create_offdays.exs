defmodule TheArk.Repo.Migrations.CreateOffdays do
  use Ecto.Migration

  def change do
    create table(:offdays) do
      add :month_number, :integer
      add :year, :integer
      add :days, {:array, :date}


      timestamps(type: :utc_datetime)
    end
  end
end
