defmodule TheArk.Repo.Migrations.CreateClasses do
  use Ecto.Migration

  def change do
    create table(:classes) do
      add :name, :string
      add :incharge, :string
      add :is_first_term_announced, :boolean, default: false
      add :is_second_term_announced, :boolean, default: false
      add :is_third_term_announced, :boolean, default: false
      add :year, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:classes, [:incharge])
  end
end
