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

alias TheArk.Repo
alias TheArk.Classes.Class
alias TheArk.Teachers.Teacher
alias TheArk.Subjects.Subject
alias TheArk.Serials.Serial

for name <- [
      "Play Group",
      "Nursery",
      "Prep",
      "One",
      "Two",
      "Three",
      "Four",
      "Five",
      "Six",
      "Seven",
      "Eight",
      "Nine",
      "Ten"
    ] do
  %Class{name: name}
  |> Repo.insert!()
end

for name <- ["Amina", "Sania", "Malaika"] do
  %Teacher{name: name}
  |> Repo.insert!()
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
