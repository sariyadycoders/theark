defmodule TheArkWeb.StudentLive do
  use TheArkWeb, :live_view

  alias TheArk.{Classes, Students}
  alias TheArkWeb.StudentIndexLive
  alias TheArkWeb.AddResultLive

  @impl true
  def mount(%{"id" => class_id}, _, socket) do
    class = Classes.get_class!(String.to_integer(class_id))
    class_options = Classes.get_class_options()
    students = get_students_and_calculate_results(class_id)

    socket
    |> assign(class: class)
    |> assign(class_options: class_options)
    |> assign(students: students)
    |> assign(open_modal_id: nil)
    |> check_result_completion()
    |> ok
  end

  @impl true
  def handle_event("show_subject_and_result", %{"student_id" => id}, socket) do
    socket
    |> redirect(to: ~p"/students/#{id}")
    |> noreply
  end

  @impl true
  def handle_event("open_students_modal", _payload, socket) do
    socket
    |> assign(open_modal_id: "students_transfer")
    |> noreply()
  end

  @impl true
  def handle_event("close_students_modal", _payload, socket) do
    socket
    |> assign(open_modal_id: nil)
    |> noreply()
  end

  @impl true
  def handle_event(
        "submit",
        %{
          "students_transfer" => %{"class" => class_id} = params
        },
        %{assigns: %{class: class}} = socket
      ) do
    selected_student_ids =
      Enum.map(params, fn {key, value} ->
        if value == "true", do: key |> String.to_integer(), else: false
      end)
      |> Enum.filter(&(&1 != false))

    class_id = String.to_integer(class_id)

    for student_id <- selected_student_ids do
      student = Students.get_student!(student_id)

      if student.class_id != class_id do
        Students.update_student(student, %{"class_id" => class_id})
      end
    end

    class = Classes.get_class!(class.id)
    students = get_students_and_calculate_results(class.id)

    socket
    |> assign(class: class)
    |> assign(students: students)
    |> assign(open_modal_id: nil)
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between">
        <h1 class="font-bold text-3xl mb-5">Students of Class <%= @class.name %></h1>
        <.button phx-click={JS.push("open_students_modal") |> show_modal("students_transfer")}>
          Transfer Students
        </.button>
      </div>
      <.modal
        :if={@open_modal_id == "students_transfer"}
        show
        id="students_transfer"
        on_cancel={JS.navigate("/classes/#{@class.id}/students")}
      >
        <%= if @is_result_completed do %>
          <.form :let={f} for={} as={:students_transfer} phx-submit="submit">
            <.input
              field={f[:class]}
              type="select"
              label="Choose Next Class"
              options={@class_options}
            />
            <div class="my-3">
              Choose students to be transferred:
            </div>
            <%= for student <- @students do %>
              <.input
                field={f["#{student.id}" |> String.to_atom()]}
                type="checkbox"
                label={student.name}
                checked={true}
              />
            <% end %>

            <div class="mt-10">
              <.button type="submit">Submit</.button>
            </div>
          </.form>
        <% else %>
          <div class="font-bold text-lg text">
            Plz submit the results completly, first !
          </div>
        <% end %>
      </.modal>
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
        <div class="col-span-3 flex items-center gap-5">
          Recent Term Result
          <div :if={!@is_result_completed} class="h-5 w-5 bg-red-600 rounded-full"></div>
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
              <span class="border-r px-2">
                <b><%= result.subject_name |> String.slice(0, 2) %></b>:
                <span><%= result.result %></span>
              </span>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def get_students_and_calculate_results(class_id) do
    students = Students.get_students_by_class_id(class_id)

    term =
      Enum.map(AddResultLive.make_term_options(), fn {_key, value} -> value end) |> List.last()

    Enum.map(students, fn student ->
      results =
        Enum.map(student.subjects, fn subject ->
          result =
            Enum.filter(subject.results, fn result ->
              result.name == term
            end)
            |> Enum.at(0)

          result =
            if result, do: result.obtained_marks, else: nil

          %{subject_name: subject.name, id: subject.subject_id, result: result}
        end)
        |> Enum.sort(&(&1.id >= &2.id))

      Map.put(student, :results, results)
    end)
  end

  defp check_result_completion(%{assigns: %{class: class}} = socket) do
    list_of_terms = Classes.make_list_of_terms()

    is_result_completed =
      Enum.all?(list_of_terms, fn term_name ->
        Enum.all?(class.students, fn student ->
          Enum.all?(student.subjects, fn subject ->
            results =
              Enum.filter(subject.results, fn result ->
                result.name == term_name
              end)

            Enum.all?(results, fn result ->
              result.obtained_marks
            end)
          end)
        end)
      end)

    socket
    |> assign(is_result_completed: is_result_completed)
  end
end
