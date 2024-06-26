defmodule TheArk.Repo.Migrations.CreateStudents do
  use Ecto.Migration

  def change do
    create table(:students) do
      add :father_name, :string
      add :name, :string
      add :address, :string
      add :date_of_birth, :date
      add :cnic, :string
      add :guardian_cnic, :string
      add :sim_number, :string
      add :whatsapp_number, :string
      add :enrollment_number, :string
      add :enrollment_date, :date
      add :class_of_enrollment, :string
      add :leaving_class, :string
      add :leaving_certificate_date, :date
      add :last_attendance_date, :date
      add :is_leaving, :boolean, default: false
      add :first_group_id, :integer
      add :class_id, references(:classes, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:students, [:cnic])
  end
end
