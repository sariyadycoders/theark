defmodule TheArk.Results.Result do
  use Ecto.Schema
  import Ecto.Changeset

  schema "results" do
    field :name, :string
    field :obtained_marks, :integer
    field :total_marks, :integer
    field :year, :integer
    field :subject_of_result, :string
    field :class_of_result, :string

    belongs_to :subject, TheArk.Subjects.Subject
    belongs_to :student, TheArk.Students.Student

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(result, attrs) do
    result
    |> cast(attrs, [:name, :total_marks, :obtained_marks, :subject_id])
    |> validate_required([:name, :subject_id])
    |> unique_constraint(:name_subject_id_year, name: :unique_name_subject_id_year)
    |> validate_obtained_marks_less_than_total_marks()
  end

  @doc false
  def yearly_changeset(result, attrs) do
    result
    |> cast(attrs, [
      :name,
      :total_marks,
      :obtained_marks,
      :student_id,
      :year,
      :subject_of_result,
      :class_of_result
    ])
    |> validate_required([
      :name,
      :total_marks,
      :obtained_marks,
      :student_id,
      :year,
      :subject_of_result,
      :class_of_result
    ])
    |> unique_constraint(:name_subject_id_year, name: :unique_name_subject_id_year)
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
