defmodule TheArkWeb.StudentLive do
  use TheArkWeb, :live_view

  alias TheArk.{Classes, Students}
  alias TheArkWeb.StudentIndexLive
  alias TheArkWeb.AddResultLive

  @impl true
  def mount(%{"id" => class_id}, _, socket) do
    class = Classes.get_class!(String.to_integer(class_id))
    students =
      get_students_and_calculate_results(class_id)

    socket
    |> assign(class: class)
    |> assign(students: students)
    |> ok
  end

  @impl true
  def handle_event("show_subject_and_result", %{"student_id" => id}, socket) do
    socket
    |> redirect(to: ~p"/students/#{id}")
    |> noreply
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="font-bold text-3xl mb-5">Students of Class <%= @class.name %></h1>
      <div class="grid grid-cols-6 items-center border-b-4 pb-2 font-bold text-lg mb-2">
        <div>
          Name
        </div>
        <div>
          Father's Name
        </div>
        <div>
          Age
        </div>
        <div class="col-span-3">
          Recent Term Result
        </div>
      </div>
      <%= for student <- @students do %>
        <div class="grid grid-cols-6 items-center pb-2">
          <div>
            <a href={"/students/#{student.id}"}><%= student.name %></a>
          </div>
          <div>
            <%= student.father_name %>
          </div>
          <div>
            <%= StudentIndexLive.calculate_age(student.date_of_birth) %>
          </div>
          <div class="col-span-3">
            <%= for result <- student.results do %>
              <span class="border-r px-2"><b><%= result.subject_name |> String.slice(0, 2) %></b>: <span><%= result.result %></span></span>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def get_students_and_calculate_results(class_id) do
    students = Students.get_students_by_class_id(class_id)
    term = Enum.map(AddResultLive.make_term_options(), fn {_key, value} -> value end) |> List.last()

    Enum.map(students, fn student ->
      results =
        Enum.map(student.subjects, fn subject ->
          result =
            (Enum.filter(subject.results, fn result ->
              result.name == term
            end) |> Enum.at(0)).obtained_marks

          %{subject_name: subject.name, id: subject.subject_id, result: result}
        end)
        |> Enum.sort(& &1.id >= &2.id)

      Map.put(student, :results, results)
    end)
  end
end
