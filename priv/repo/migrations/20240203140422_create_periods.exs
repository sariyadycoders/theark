defmodule TheArk.Repo.Migrations.CreatePeriods do
  use Ecto.Migration

  def change do
    create table(:periods) do
      add :period_number, :integer
      add :subject, :string
      add :class_id, references(:classes, on_delete: :delete_all)
      add :teacher_id, references(:teachers)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:periods, [:period_number, :teacher_id], name: "unique_number_teacher_index")
    create unique_index(:periods, [:period_number, :class_id], name: "unique_number_class_index")
  end
end
