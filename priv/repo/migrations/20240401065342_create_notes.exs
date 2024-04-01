defmodule TheArk.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add :title, :string
      add :description, :string
      add :finance_id, references(:finances, on_delete: :delete_all)
      add :student_id, references(:students, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
