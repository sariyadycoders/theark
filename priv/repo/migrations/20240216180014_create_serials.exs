defmodule TheArk.Repo.Migrations.CreateSerials do
  use Ecto.Migration

  def change do
    create table(:serials) do
      add :name, :string
      add :number, :string

      timestamps(type: :utc_datetime)
    end
  end
end
