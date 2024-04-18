defmodule TheArk.Repo.Migrations.CreateAttendances do
  use Ecto.Migration

  def change do
    create table(:attendances) do
      add :date, :date
      add :entry, :string

      add :is_monthly, :boolean
      add :number_of_leaves, :integer
      add :leave_days, {:array, :date}
      add :number_of_absents, :integer
      add :absent_days, {:array, :date}
      add :number_of_half_leaves, :integer
      add :half_leave_days, {:array, :date}

      add :teacher_id, references(:teachers, on_delete: :delete_all)
      add :student_id, references(:students, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
