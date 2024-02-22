defmodule TheArk.Repo.Migrations.CreateClassresults do
  use Ecto.Migration

  def change do
    create table(:classresults) do
      add :name, :string
      add :obtained_marks, :integer
      add :total_marks, :integer
      add :students_appeared, :integer
      add :absent_students, {:array, :string}, default: []
      add :subject_id, references(:subjects, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
