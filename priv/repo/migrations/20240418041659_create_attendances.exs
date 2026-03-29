defmodule TheArk.Repo.Migrations.CreateAttendances do
  use Ecto.Migration

  def change do
    create table(:attendances) do
      add :date, :date
      add :entry, :string
      add :time, :time

      add :is_monthly, :boolean
      add :month_number, :integer
      add :year, :integer
      add :number_of_leaves, :integer
      add :leave_days, {:array, :date}
      add :number_of_absents, :integer
      add :absent_days, {:array, :date}
      add :number_of_half_leaves, :integer
      add :half_leave_days, {:array, :date}
      add :number_of_presents, :integer
      add :present_days, {:array, :date}

      add :teacher_id, references(:teachers, on_delete: :delete_all)
      add :student_id, references(:students, on_delete: :delete_all)
      add :class_id, references(:classes, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
