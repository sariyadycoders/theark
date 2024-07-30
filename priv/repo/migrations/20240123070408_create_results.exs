defmodule TheArk.Repo.Migrations.CreateResults do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :name, :string
      add :total_marks, :integer
      add :obtained_marks, :integer
      add :year, :integer
      add :subject_of_result, :string

      add :subject_id, references(:subjects, on_delete: :delete_all)
      add :student_id, references(:students, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:results, [:name, :subject_id, :year], name: :unique_name_subject_id_year)
  end
end
