defmodule TheArk.Repo.Migrations.AddGroupIdToStudents do
  use Ecto.Migration

  def change do
    alter table(:students) do
      add :group_id, references(:groups, on_delete: :nothing)
    end
  end
end
