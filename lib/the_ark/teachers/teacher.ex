defmodule TheArk.Teachers.Teacher do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teachers" do
    field :date_of_joining, :date
    field :date_of_leaving, :date
    field :name, :string
    field :residence, :string

    has_many :subjects, TheArk.Subjects.Subject

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(teacher, attrs) do
    teacher
    |> cast(attrs, [:name, :date_of_joining, :residence, :date_of_leaving])
    |> validate_required([:name])
    |> validate_length(:name, min: 5)
  end
end
