defmodule TheArk.Repo.Migrations.CreateResults do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :name, :string
      add :total_marks, :integer
      add :obtained_marks, :integer
      add :subject_id, references(:subjects, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:results, [:name, :subject_id])
  end
end
