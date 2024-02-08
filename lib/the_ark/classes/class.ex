defmodule TheArk.Classes.Class do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classes" do
    field :name, :string
    field :incharge, :string
    field :is_first_term_announced, :boolean, default: false
    field :is_first_term_result_completed, :boolean, default: false
    field :is_second_term_announced, :boolean, default: false
    field :is_second_term_result_completed, :boolean, default: false
    field :is_third_term_announced, :boolean, default: false
    field :is_third_term_result_completed, :boolean, default: false

    has_many :periods, TheArk.Periods.Period, on_delete: :delete_all
    has_many :students, TheArk.Students.Student, on_delete: :delete_all
    has_many :subjects, TheArk.Subjects.Subject, on_delete: :delete_all
    has_many :slos, TheArk.Slos.Slo, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(class, attrs) do
    class
    |> cast(attrs, [:name, :incharge, :is_first_term_announced, :is_first_term_result_completed, :is_second_term_announced, :is_second_term_result_completed, :is_third_term_announced, :is_third_term_result_completed])
    |> validate_required([:name])
    |> validate_length(:name, min: 5)
    |> unsafe_validate_unique(:incharge, TheArk.Repo, message: "This teacher is incharge of another class")
    |> unique_constraint([:incharge])

  end
end
