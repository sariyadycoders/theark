defmodule TheArkWeb.ClassResultLive do
  use TheArkWeb, :live_view

  alias TheArk.Classes
  alias TheArk.Classresults

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    Classresults.prepare_class_results(id)
    class = Classes.get_class!(id)

    socket
    |> assign(class: class)
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="font-bold text-3xl mb-5">Results for Class <%= @class.name %></h1>
      <div class="grid grid-cols-6 items-center border-b-4 pb-2 font-bold text-md">
        <div>
          Subject
        </div>
        <div class="col-span-2">
          Students Appeared
        </div>
        <div>
          Total Marks
        </div>
        <div>
          Average O.Marks
        </div>
        <div>
          %
        </div>
      </div>
      <%= for result_name <- Classes.make_list_of_terms() do %>
        <div class="grid grid-cols-6 gap-2">
          <div class="col-span-6 capitalize font-bold my-2">
            <%= String.replace(result_name, "_", " ") %>
          </div>
          <%= for subject <- @class.subjects do %>
            <div>
              <a href={"/classes/#{@class.id}/results/#{subject.name}/?term=#{result_name}"}>
                <%= subject.name %>
              </a>
            </div>
            <div class="col-span-2">
              <div>
                <%= get_number_of_students_appeared(subject.classresults, result_name) %> out of <%= Enum.count(
                  @class.students
                ) %>
              </div>
              <div>
                <b>Absentee's:</b>
                <span>
                  <%= for name <- get_names_of_absentees(subject.classresults, result_name) do %>
                    <%= name %>,
                  <% end %>
                </span>
              </div>
            </div>
            <div>
              <%= get_total_marks_of_term_from_results(subject.classresults, result_name) %>
            </div>
            <div>
              <%= get_obtained_marks_of_term_from_results(subject.classresults, result_name) %>
            </div>
            <div>
              <%= get_percentage_of_marks(subject.classresults, result_name) %>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  def get_obtained_marks_of_term_from_results(results, term_name) do
    (Enum.filter(results, fn result -> result.name == term_name end) |> Enum.at(0)).obtained_marks
  end

  def get_total_marks_of_term_from_results(results, term_name) do
    t_marks =
      (Enum.filter(results, fn result -> result.name == term_name end) |> Enum.at(0)).total_marks

    if t_marks do
      t_marks
    else
      0
    end
  end

  def get_percentage_of_marks(results, term_name) do
    if (Enum.filter(results, fn result -> result.name == term_name end)
        |> Enum.at(0)).total_marks do
      (Enum.filter(results, fn result -> result.name == term_name end)
       |> Enum.at(0)).obtained_marks /
        (Enum.filter(results, fn result -> result.name == term_name end)
         |> Enum.at(0)).total_marks * 100
    else
      0
    end
  end

  def get_number_of_students_appeared(results, term_name) do
    if (Enum.filter(results, fn result -> result.name == term_name end)
        |> Enum.at(0)).students_appeared > 0 and
         !is_nil(
           (Enum.filter(results, fn result -> result.name == term_name end)
            |> Enum.at(0)).students_appeared
         ) do
      (Enum.filter(results, fn result -> result.name == term_name end)
       |> Enum.at(0)).students_appeared
    else
      0
    end
  end

  def get_names_of_absentees(results, term_name) do
    (Enum.filter(results, fn result -> result.name == term_name end)
     |> Enum.at(0)).absent_students
  end
end
