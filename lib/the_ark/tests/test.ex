defmodule TheArk.Tests.Test do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tests" do
    field :subject, :string
    field :total_marks, :integer
    field :obtained_marks, :integer
    field :date_of_test, :date
    field :is_class_test, :boolean, default: false

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
      :student_id,
      :class_id
    ])
    |> validate_required([:subject, :total_marks, :date_of_test, :class_id])
  end
end
