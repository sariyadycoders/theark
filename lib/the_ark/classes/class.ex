defmodule TheArk.Classes.Class do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classes" do
    field :name, :string
    field :incharge, :string
    field :first_period_subject, :string
    field :first_period_teacher, :string
    field :second_period_subject, :string
    field :second_period_teacher, :string
    field :third_period_subject, :string
    field :third_period_teacher, :string
    field :four_period_subject, :string
    field :four_period_teacher, :string
    field :five_period_subject, :string
    field :five_period_teacher, :string
    field :six_period_subject, :string
    field :six_period_teacher, :string
    field :seven_period_subject, :string
    field :seven_period_teacher, :string
    field :eight_period_subject, :string
    field :eight_period_teacher, :string
    field :nine_period_subject, :string
    field :nine_period_teacher, :string
    field :is_first_term_announced, :boolean, default: false
    field :is_first_term_result_completed, :boolean, default: false
    field :is_second_term_announced, :boolean, default: false
    field :is_second_term_result_completed, :boolean, default: false
    field :is_third_term_announced, :boolean, default: false
    field :is_third_term_result_completed, :boolean, default: false

    has_many :students, TheArk.Students.Student, on_delete: :delete_all
    has_many :subjects, TheArk.Subjects.Subject, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(class, attrs) do
    class
    |> cast(attrs, [:name, :incharge])
    |> validate_required([:name])
    |> validate_length(:name, min: 5)
    |> unsafe_validate_unique(:incharge, TheArk.Repo, message: "This teacher is incharge of another class")
    |> unsafe_validate_unique([:first_period_teacher, :second_period_teacher, :third_period_teacher, :four_period_teacher, :five_period_teacher, :six_period_teacher, :seven_period_teacher, :eight_period_teacher, :nine_period_teacher], TheArk.Repo, message: "This teacher is busy")
    |> unique_constraint([:incharge, :first_period_teacher, :second_period_teacher, :third_period_teacher, :four_period_teacher, :five_period_teacher, :six_period_teacher, :seven_period_teacher, :eight_period_teacher, :nine_period_teacher])

  end
end
