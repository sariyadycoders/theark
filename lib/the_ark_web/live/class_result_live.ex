defmodule TheArkWeb.ClassResultLive do
  use TheArkWeb, :live_view

  alias TheArk.Classes
  alias TheArk.Results

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    Results.prepare_class_results(id)
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
        <div class="grid grid-cols-4 items-center border-b-4 pb-2 font-bold text-md">
          <div>
            Subject
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
          <div class="grid grid-cols-4 items-center">
            <div class="col-span-4 capitalize font-bold my-2">
              <%= String.replace(result_name, "_", " ") %>
            </div>
            <%= for subject <- @class.subjects do %>
              <div>
                <%= subject.name %>
              </div>
              <div>
                <%= get_total_marks_of_term_from_results(subject.results, result_name) %>
              </div>
              <div>
                <%= get_obtained_marks_of_term_from_results(subject.results, result_name) %>
              </div>
              <div>
                <%= get_percentage_of_marks(subject.results, result_name) %>
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
    t_marks = (Enum.filter(results, fn result -> result.name == term_name end) |> Enum.at(0)).total_marks
    if t_marks do
      t_marks
    else
      0
    end
  end

  def get_percentage_of_marks(results, term_name) do
    if (Enum.filter(results, fn result -> result.name == term_name end) |> Enum.at(0)).total_marks do
    (((Enum.filter(results, fn result -> result.name == term_name end) |> Enum.at(0)).obtained_marks) / ((Enum.filter(results, fn result -> result.name == term_name end) |> Enum.at(0)).total_marks))*100
    else
      0
    end
  end
end
