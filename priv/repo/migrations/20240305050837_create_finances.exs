defmodule TheArk.Repo.Migrations.CreateFinances do
  use Ecto.Migration

  def change do
    create table(:finances) do
      add :transaction_id, :string
      add :is_bill, :boolean, default: false
      add :absent_fine_date, :date

      timestamps(type: :utc_datetime)
    end
  end
end
