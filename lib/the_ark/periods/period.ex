defmodule TheArk.Periods.Period do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "periods" do
    field :period_number, :integer
    field :subject, :string

    belongs_to :teacher, TheArk.Teachers.Teacher
    belongs_to :class, TheArk.Classes.Class

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(period, attrs) do
    period
    |> cast(attrs, [:period_number, :subject, :teacher_id, :class_id])
    |> validate_required([:period_number])
    |> unsafe_validate_unique([:teacher_id, :period_number], TheArk.Repo, message: "teacher is busy")
    |> unsafe_validate_unique([:class_id, :period_number], TheArk.Repo, message: "class is busy")
    |> unique_constraint(:unique_number_teacher_index, name: "unique_number_teacher_index", message: "teacher is busy")
    |> unique_constraint(:unique_number_class_index, name: "unique_number_class_index")
  end
end
