defmodule TheArk.Repo.Migrations.CreateClasses do
  use Ecto.Migration

  def change do
    create table(:classes) do
      add :name, :string
      add :incharge, :string
      add :first_period_subject, :string
      add :first_period_teacher, :string
      add :second_period_subject, :string
      add :second_period_teacher, :string
      add :third_period_subject, :string
      add :third_period_teacher, :string
      add :four_period_subject, :string
      add :four_period_teacher, :string
      add :five_period_subject, :string
      add :five_period_teacher, :string
      add :six_period_subject, :string
      add :six_period_teacher, :string
      add :seven_period_subject, :string
      add :seven_period_teacher, :string
      add :eight_period_subject, :string
      add :eight_period_teacher, :string
      add :nine_period_subject, :string
      add :nine_period_teacher, :string
      add :is_first_term_announced, :boolean, default: false
      add :is_first_term_result_completed, :boolean, default: false
      add :is_second_term_announced, :boolean, default: false
      add :is_second_term_result_completed, :boolean, default: false
      add :is_third_term_announced, :boolean, default: false
      add :is_third_term_result_completed, :boolean, default: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:classes, [:incharge])
    create unique_index(:classes, [:first_period_teacher])
    create unique_index(:classes, [:second_period_teacher])
    create unique_index(:classes, [:third_period_teacher])
    create unique_index(:classes, [:four_period_teacher])
    create unique_index(:classes, [:five_period_teacher])
    create unique_index(:classes, [:six_period_teacher])
    create unique_index(:classes, [:seven_period_teacher])
    create unique_index(:classes, [:eight_period_teacher])
    create unique_index(:classes, [:nine_period_teacher])
  end
end
