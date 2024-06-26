defmodule TheArk.Periods.Period do
  use Ecto.Schema
  import Ecto.Changeset

  schema "periods" do
    field :period_number, :integer
    field :subject, :string
    field :start_time, :time
    field :end_time, :time
    field :duration, :integer
    field :is_custom_set, :boolean

    belongs_to :class, TheArk.Classes.Class
    belongs_to :teacher, TheArk.Teachers.Teacher

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(period, attrs) do
    period
    |> cast(attrs, [
      :period_number,
      :subject,
      :teacher_id,
      :start_time,
      :end_time,
      :duration,
      :is_custom_set,
      :class_id
    ])
    |> validate_required([:period_number])
    |> unsafe_validate_unique([:teacher_id, :period_number], TheArk.Repo,
      message: "teacher is busy"
    )
    |> unsafe_validate_unique([:subject, :class_id], TheArk.Repo,
      message: "duplication of subject"
    )
    |> unsafe_validate_unique([:class_id, :period_number], TheArk.Repo, message: "class is busy")
    |> unique_constraint(:unique_number_teacher_index,
      name: "unique_number_teacher_index",
      message: "teacher is busy"
    )
    |> unique_constraint(:unique_number_teacher_index,
      name: "unique_class_subject_index",
      message: "duplication of subject"
    )
    |> unique_constraint(:unique_number_class_index, name: "unique_number_class_index")
  end
end
