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
    |> assign(term_name: nil)
    |> ok()
  end

  @impl true
  def handle_event("choose_term", %{"term_name" => term_name}, socket) do
    socket
    |> assign(term_name: term_name)
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="font-bold text-3xl mb-5">Results for Class <%= @class.name %></h1>

      <div class="flex items-center gap-2 my-5">
        <%= for term_name <- Classes.make_list_of_terms() do %>
          <.button phx-click="choose_term" phx-value-term_name={term_name}>
            See <%= term_name |> String.replace("_", " ") %> Result Sheet
          </.button>
        <% end %>
      </div>

      <div :if={@term_name} class="w-full p-5 border rounded-lg my-5">
        <div class="grid grid-cols-8 items-center font-bold">
          <div class="border flex flex-col py-2">
            <div class="col-span-2 text-center">S. Name</div>
            <div class="col-span-2 text-sm font-normal text-center text-white">random</div>
          </div>
          <%= for subject <- @class.subjects do %>
            <div class="border flex flex-col py-2">
              <div class="col-span-2 text-center"><%= subject.name %></div>
              <div class="col-span-2 text-sm font-normal text-center">
                <%= get_total_marks_of_term_from_results(subject.classresults, @term_name) %>
              </div>
            </div>
          <% end %>
        </div>
        <%= for student <- @class.students do %>
          <div class="grid grid-cols-8 items-center">
            <div class="border pl-2 py-1">
              <%= student.name %>
            </div>
            <%= for subject <- student.subjects do %>
              <div class="flex border justify-center py-1">
                <%= get_obtained_marks_of_term_from_results(subject.results, @term_name) %>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>

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
                  <%= for {name, index} <- Enum.with_index(get_names_of_absentees(subject.classresults, result_name)) do %>
                    <%= name %><%= if index ==
                                        Enum.count(
                                          get_names_of_absentees(subject.classresults, result_name)
                                        ) - 1,
                                      do: "",
                                      else: "," %>
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
    o_marks =
      (Enum.filter(results, fn result -> result.name == term_name end)
       |> Enum.at(0)).obtained_marks

    if o_marks do
      o_marks
    else
      0
    end
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
        |> Enum.at(0)).total_marks &&
         (Enum.filter(results, fn result -> result.name == term_name end)
          |> Enum.at(0)).obtained_marks do
      ((Enum.filter(results, fn result -> result.name == term_name end)
        |> Enum.at(0)).obtained_marks /
         (Enum.filter(results, fn result -> result.name == term_name end)
          |> Enum.at(0)).total_marks * 100)
      |> round()
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
