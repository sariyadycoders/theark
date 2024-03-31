defmodule TheArk.Repo.Migrations.CreateTransactionDetails do
  use Ecto.Migration

  def change do
    create table(:transaction_details) do
      add :title, :string
      add :month, :string
      add :total_amount, :integer
      add :paid_amount, :integer
      add :due_amount, :integer
      add :is_accected, :boolean
      add :finance_id, references(:finances, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
