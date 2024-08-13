# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TheArk.Repo.insert!(%TheArk.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TheArk.{
  Repo,
  Teachers,
  Teachers.Teacher,
  Classes.Class,
  Subjects.Subject,
  Serials.Serial,
  Organizations.Organization,
  Roles.Role,
  Students.Student,
  Students,
  Groups
}

for {name, dig} <- [
      {"Play Group", 1},
      {"Nursery", 2},
      {"Prep", 3},
      {"One", 4},
      {"Two", 5},
      {"Three", 6},
      {"Four", 7},
      {"Five", 8},
      {"Six", 9},
      {"Seven", 10},
      {"Eight", 11},
      {"Nine", 12},
      {"Ten", 13}
    ] do
  class = %Class{name: name} |> Repo.insert!() |> IO.inspect()

  for num <- 1..3 do
    {:ok, student} =
      %Student{
        name: "Bilal #{num} #{name}",
        father_name: "Haq",
        address: "random",
        date_of_birth: Date.utc_today(),
        cnic: "341#{dig}-9485863-#{num}",
        guardian_cnic: "34101-9485863-7",
        sim_number: "03000000000",
        whatsapp_number: "03000000000",
        enrollment_number: "1",
        enrollment_date: Date.utc_today(),
        class_of_enrollment: name,
        class_id: class.id
      }
      |> Repo.insert()
      |> Students.create_group()
      |> Students.create_attendance_of_month()
  end
end

for name <- ["Amina", "Sania", "Malaika"] do
  %Teacher{name: name, registration_date: Date.utc_today()}
  |> Repo.insert()
  |> Teachers.create_attendance_of_month()
end

for name <- [
      "Urdu",
      "English",
      "Maths",
      "Islamiat C",
      "Islamiat O",
      "Science",
      "Computer",
      "General Knowledge",
      "Nazra",
      "Tarjuma",
      "Physics",
      "Chemistry",
      "Biology",
      "Geology",
      "Social Study",
      "Home Economics"
    ] do
  %Subject{name: name}
  |> Repo.insert!()
end

year = Date.utc_today().year |> Integer.to_string() |> String.slice(2, 2)

for name <- ["teacher", "student"] do
  %Serial{
    name: name,
    number: "tams-#{if name == "teacher", do: "t", else: "s"}-#{year}-00000"
  }
  |> Repo.insert()
end

%Serial{name: "finance", number: "tams-f-#{year}-00000"} |> Repo.insert()

organization = %Organization{
  name: "the_ark",
  number_of_students: 150,
  number_of_years: 6,
  number_of_staff: 12
}

{:ok, organization} = Repo.insert(organization)

%Role{
  name: "Abu Bakr Yonas",
  role: "Principal",
  contact_number: "0315-6242622",
  organization_id: organization.id
}
|> Repo.insert()

%Role{
  name: "Qari Abdul-Maalik Mujahid",
  role: "Chairman",
  contact_number: "0321-7401330",
  organization_id: organization.id
}
|> Repo.insert()

%Role{
  name: "Saaria Mujahid",
  role: "Coordinator",
  contact_number: "0304-2728859",
  organization_id: organization.id
}
|> Repo.insert()
