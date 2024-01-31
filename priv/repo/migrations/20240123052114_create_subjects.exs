defmodule TheArk.Repo.Migrations.CreateSubjects do
  use Ecto.Migration

  def change do
    create table(:subjects) do
      add :name, :string
      add :is_class_subject, :boolean, default: false
      add :subject_id, :integer

      add :teacher_id, references(:teachers, on_delete: :nothing)
      add :student_id, references(:students, on_delete: :delete_all)
      add :class_id, references(:classes, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
