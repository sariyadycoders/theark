defmodule TheArk.Students.Student do
  use Ecto.Schema
  import Ecto.Changeset

  schema "students" do
    field :age, :integer
    field :father_name, :string
    field :name, :string

    belongs_to :class, TheArk.Classes.Class
    has_many :subjects, TheArk.Subjects.Subject, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [:name, :age, :father_name, :class_id])
    |> validate_required([:name])
    |> validate_length(:name, min: 5)
  end
end
