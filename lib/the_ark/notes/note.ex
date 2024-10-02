defmodule TheArk.Notes.Note do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notes" do
    field :description, :string
    field :title, :string
    belongs_to :finance, TheArk.Finances.Finance
    belongs_to :student, TheArk.Students.Student
    belongs_to :teacher, TheArk.Teachers.Teacher

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:title, :description, :finance_id, :student_id, :teacher_id])
    |> validate_required([:title, :description])
  end
end
