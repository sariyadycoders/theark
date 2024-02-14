defmodule TheArk.Students.Student do
  use Ecto.Schema
  import Ecto.Changeset

  schema "students" do
    field :father_name, :string
    field :name, :string
    field :address, :string
    field :date_of_birth, :date
    field :cnic, :string
    field :guardian_cnic, :string
    field :sim_number, :string
    field :whatsapp_number, :string
    field :class_of_enrollment, :string
    field :enrollment_number, :integer
    field :enrollment_date, :date
    field :leaving_class, :string
    field :leaving_certificate_date, :date
    field :last_attendance_date, :date
    field :is_leaving, :boolean, default: false

    belongs_to :class, TheArk.Classes.Class
    has_many :subjects, TheArk.Subjects.Subject, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [:name, :father_name, :date_of_birth, :cnic, :guardian_cnic, :sim_number, :whatsapp_number, :enrollment_number, :enrollment_date, :class_of_enrollment, :leaving_class, :leaving_certificate_date, :last_attendance_date, :is_leaving, :class_id])
    |> validate_required([:name])
    |> validate_length(:name, min: 5)
    |> validate_format(:cnic, ~r/^\d{5}-\d{7}-\d$/, message: "must match the pattern 00000-0000000-0")
    |> validate_format(:guardian_cnic, ~r/^\d{5}-\d{7}-\d$/, message: "must match the pattern 00000-0000000-0")
    |> validate_format(:whatsapp_number, ~r/^03\d{9}$/, message: "must start with 03 and have exactly 11 characters")
    |> validate_format(:sim_number, ~r/^03\d{9}$/, message: "must start with 03 and have exactly 11 characters")
    |> unsafe_validate_unique(:cnic, TheArk.Repo, message: "This is a duplicate CNIC")
    |> unique_constraint([:cnic])

  end

  def leaving_changeset(student, attrs) do
    student
    |> cast(attrs, [:leaving_class, :leaving_certificate_date, :last_attendance_date, :is_leaving])
    |> validate_required([:leaving_class, :leaving_certificate_date, :last_attendance_date, :is_leaving])
  end
end
