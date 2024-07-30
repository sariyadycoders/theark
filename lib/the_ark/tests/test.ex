defmodule TheArk.Tests.Test do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tests" do
    field :subject, :string
    field :total_marks, :integer
    field :obtained_marks, :integer
    field :date_of_test, :date
    field :is_class_test, :boolean, default: false
    field :is_closed, :boolean

    belongs_to :student, TheArk.Students.Student
    belongs_to :class, TheArk.Classes.Class

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(test, attrs) do
    test
    |> cast(attrs, [
      :subject,
      :total_marks,
      :obtained_marks,
      :date_of_test,
      :is_class_test,
      :student_id
    ])
    |> validate_required([:subject, :total_marks, :date_of_test, :student_id])
  end

  def student_submit_changeset(test, attrs) do
    test
    |> cast(attrs, [
      :subject,
      :total_marks,
      :obtained_marks,
      :date_of_test,
      :is_class_test,
      :student_id
    ])
    |> validate_required([:subject, :total_marks, :date_of_test, :student_id, :obtained_marks])
    |> validate_obtained_marks_less_than_total_marks()
  end

  @doc false
  def class_changeset(test, attrs) do
    test
    |> cast(attrs, [
      :subject,
      :total_marks,
      :obtained_marks,
      :date_of_test,
      :is_class_test,
      :class_id
    ])
    |> validate_required([:subject, :total_marks, :date_of_test, :class_id])
    |> unsafe_validate_unique([:subject, :class_id, :date_of_test], TheArk.Repo,
      message: "Already this subject is tested on same day"
    )
    |> unique_constraint(:unique_subject_date_class_id, name: "unique_subject_date_class_id")
    |> validate_obtained_marks_less_than_total_marks()
  end

  def validate_obtained_marks_less_than_total_marks(changeset) do
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
