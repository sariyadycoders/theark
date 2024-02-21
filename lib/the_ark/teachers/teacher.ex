defmodule TheArk.Teachers.Teacher do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teachers" do
    field :name, :string
    field :father_name, :string
    field :education, :string
    field :address, :string
    field :cnic, :string
    field :sim_number, :string
    field :whatsapp_number, :string
    field :registration_number, :string
    field :registration_date, :date
    field :leaving_certificate_date, :date
    field :last_attendance_date, :date
    field :is_leaving, :boolean, default: false

    has_many :subjects, TheArk.Subjects.Subject
    has_many :periods, TheArk.Periods.Period

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(teacher, attrs) do
    teacher
    |> cast(attrs, [
      :name,
      :father_name,
      :address,
      :education,
      :cnic,
      :sim_number,
      :whatsapp_number,
      :registration_number,
      :registration_date
    ])
    |> validate_required([:name, :father_name, :address, :education, :cnic, :sim_number])
    |> validate_format(:cnic, ~r/^\d{5}-\d{7}-\d$/,
      message: "must match the pattern 00000-0000000-0"
    )
    |> validate_format(:whatsapp_number, ~r/^03\d{9}$/,
      message: "must start with 03 and have exactly 11 numbers"
    )
    |> validate_format(:sim_number, ~r/^03\d{9}$/,
      message: "must start with 03 and have exactly 11 numbers"
    )
    |> unsafe_validate_unique(:cnic, TheArk.Repo, message: "This is a duplicate CNIC")
    |> unique_constraint([:cnic])
  end
end
