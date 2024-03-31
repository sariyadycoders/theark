defmodule TheArk.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
      add :monthly_fee, :integer
      add :is_main, :boolean

      timestamps(type: :utc_datetime)
    end
  end
end
