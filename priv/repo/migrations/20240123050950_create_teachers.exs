defmodule TheArk.Repo.Migrations.CreateTeachers do
  use Ecto.Migration

  def change do
    create table(:teachers) do
      add :name, :string
      add :father_name, :string
      add :address, :string
      add :education, :string
      add :cnic, :string
      add :sim_number, :string
      add :whatsapp_number, :string
      add :registration_number, :string
      add :registration_date, :date
      add :leaving_certificate_date, :date
      add :last_attendance_date, :date
      add :is_leaving, :boolean, default: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:teachers, [:cnic])
  end
end
