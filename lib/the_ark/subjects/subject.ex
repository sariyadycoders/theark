defmodule TheArk.Subjects.Subject do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subjects" do
    field :name, :string
    field :is_class_subject, :boolean, default: false
    field :subject_id, :integer

    belongs_to :student, TheArk.Students.Student
    belongs_to :teacher, TheArk.Teachers.Teacher
    belongs_to :class, TheArk.Classes.Class

    has_many :results, TheArk.Results.Result, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subject, attrs) do
    subject
    |> cast(attrs, [:name, :student_id, :teacher_id, :class_id, :is_class_subject, :subject_id])
    |> validate_required([:name])
  end
end
