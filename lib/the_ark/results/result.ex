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
    |> validate_required([:name])
  end
end
