defmodule TheArk.Repo.Migrations.CreateTests do
  use Ecto.Migration

  def change do
    create table(:tests) do
      add :subject, :string
      add :total_marks, :integer
      add :obtained_marks, :integer
      add :date_of_test, :date
      add :is_class_test, :boolean
      add :student_id, references(:students, on_delete: :delete_all)
      add :class_id, references(:classes, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
