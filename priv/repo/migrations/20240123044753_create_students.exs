defmodule TheArk.Repo.Migrations.CreateStudents do
  use Ecto.Migration

  def change do
    create table(:students) do
      add :name, :string
      add :age, :integer
      add :father_name, :string
      add :class_id, references(:classes, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
