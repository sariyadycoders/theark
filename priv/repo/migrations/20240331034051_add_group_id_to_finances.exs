defmodule TheArk.Repo.Migrations.AddGroupIdToFinances do
  use Ecto.Migration

  def change do
    alter table(:finances) do
      add :group_id, references(:groups, on_delete: :delete_all)
    end
  end
end
