defmodule TheArk.Repo.Migrations.AddTestIdToResutls do
  use Ecto.Migration

  def change do
    alter table(:results) do
      add :test_id, references(:tests, on_delete: :delete_all)
    end
  end
end
