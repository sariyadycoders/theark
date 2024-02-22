defmodule TheArk.Classresults.Classresult do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classresults" do
    field :name, :string
    field :obtained_marks, :integer
    field :total_marks, :integer
    field :students_appeared, :integer
    field :absent_students, {:array, :string}

    belongs_to :subject, TheArk.Subjects.Subject

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(classresult, attrs) do
    classresult
    |> cast(attrs, [
      :name,
      :obtained_marks,
      :total_marks,
      :students_appeared,
      :absent_students,
      :subject_id
    ])
    |> validate_required([:name, :subject_id])
  end
end
