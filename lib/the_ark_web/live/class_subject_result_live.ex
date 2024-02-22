defmodule TheArkWeb.ClassSubjectResultLive do
  use TheArkWeb, :live_view

  alias TheArk.Classes

  @impl true
  def mount(%{"id" => class_id, "subject_name" => subject_name, "term" => term}, _, socket) do
    class = Classes.get_class!(class_id)
    results = prepare_results(class, subject_name, term)

    socket
    |> assign(class: class)
    |> assign(results: results)
    |> assign(subject_name: subject_name)
    |> assign(term: term)
    |> ok
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="font-bold text-3xl mb-5 capitalize">
        <%= String.replace(@term, "_", " ") |> String.capitalize() %> result of Class <%= @class.name %> for subject <%= @subject_name %>
      </h1>
      <div class="grid grid-cols-4 items-center border-b-4 pb-2 font-bold text-md mb-2">
        <div>
          Student Name
        </div>
        <div>
          Total Marks
        </div>
        <div>
          Obtained Marks
        </div>
        <div>
          %
        </div>
      </div>
      <%= for result <- @results do %>
        <div class="grid grid-cols-4 items-center pb-2">
          <div>
            <%= result.student_name %>
          </div>
          <div>
            <%= result.result.total_marks %>
          </div>
          <div>
            <%= result.result.obtained_marks %>
          </div>
          <div>
            <%= get_percentage(result.result) %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def prepare_results(class, subject_name, term) do
    Enum.map(class.students, fn student ->
      related_subject =
        Enum.filter(student.subjects, fn subject ->
          subject.name == subject_name
        end)
        |> Enum.at(0)

      related_result =
        Enum.filter(related_subject.results, fn result ->
          result.name == term
        end)
        |> Enum.at(0)

      %{student_name: student.name, result: related_result}
    end)
  end

  def get_percentage(result) do
    if result.obtained_marks do
      (result.obtained_marks / result.total_marks * 100) |> round()
    else
      0
    end
  end
end
