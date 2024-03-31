defmodule TheArk.Repo.Migrations.CreateFinances do
  use Ecto.Migration

  def change do
    create table(:finances) do
      add :transaction_id, :string
      add :is_bill, :boolean, default: false

      timestamps(type: :utc_datetime)
    end
  end
end
