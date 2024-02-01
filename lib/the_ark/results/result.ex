defmodule TheArk.Results.Result do
  use Ecto.Schema
  import Ecto.Changeset

  schema "results" do
    field :name, :string
    field :obtained_marks, :integer
    field :total_marks, :integer

    belongs_to :subject, TheArk.Subjects.Subject

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(result, attrs) do
    result
    |> cast(attrs, [:name, :total_marks, :obtained_marks, :subject_id])
    |> validate_required([:name, :subject_id])
    |> unique_constraint(:name_subject_id, name: :name, subject_id: :subject_id)
    |> validate_obtained_marks_less_than_total_marks()
  end

  defp validate_obtained_marks_less_than_total_marks(changeset) do
    total_marks = get_field(changeset, :total_marks)
    obtained_marks = get_field(changeset, :obtained_marks)

    if is_nil(total_marks) or is_nil(obtained_marks) do
      changeset
    else
      if obtained_marks > total_marks do
        changeset
        |> add_error(:obtained_marks, "should be less than or equal to total marks")
      else
        changeset
      end
    end
  end
end
