defmodule TheArk.Repo.Migrations.CreateFinances do
  use Ecto.Migration

  def change do
    create table(:finances) do
      add :transaction_id, :string
      add :student_id, references(:students, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end