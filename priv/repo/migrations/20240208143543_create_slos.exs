defmodule TheArk.Repo.Migrations.CreateSlos do
  use Ecto.Migration

  def change do
    create table(:slos) do
      add :description, :string
      add :class_id, references(:classes, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
