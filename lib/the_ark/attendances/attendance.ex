defmodule TheArk.Attendances.Attendance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attendances" do
    field :date, :date
    field :entry, :string

    field :is_monthly, :boolean
    field :month_number, :integer
    field :year, :integer
    field :number_of_leaves, :integer
    field :leave_days, {:array, :date}
    field :number_of_absents, :integer
    field :absent_days, {:array, :date}
    field :number_of_half_leaves, :integer
    field :half_leave_days, {:array, :date}

    belongs_to :teacher, TheArk.Teachers.Teacher
    belongs_to :student, TheArk.Students.Student
    belongs_to :class, TheArk.Classes.Class

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(attendance, attrs) do
    attendance
    |> cast(attrs, [
      :date,
      :entry,
      :is_monthly,
      :month_number,
      :year,
      :number_of_leaves,
      :leave_days,
      :number_of_absents,
      :absent_days,
      :number_of_half_leaves,
      :half_leave_days,
      :teacher_id,
      :student_id,
      :class_id
    ])
    |> validate_required([])
  end
end
