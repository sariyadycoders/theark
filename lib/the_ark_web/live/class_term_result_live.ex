defmodule TheArkWeb.ClassTermResultLive do
  use TheArkWeb, :live_view

  import TheArkWeb.ClassResultLive, only: [get_total_marks_of_term_from_results: 2, get_obtained_marks_of_term_from_results: 2]

  alias TheArk.Classes

  @impl true
  def mount(%{"id" => class_id, "term" => term}, _session, socket) do
    class = Classes.get_class!(String.to_integer(class_id))

    socket
    |> assign(class: class)
    |> assign(term_name: term)
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="w-full p-5 border rounded-lg my-5">
        <div class="text-center text-lg font-bold">
          Result Sheet for Class: <b><%= @class.name %> (<%= @term_name |> String.splitter("_") |> Enum.join(" ") |> String.capitalize() %>)</b>
        </div>
        <div class="my-2 font-bold">Regular Subjects</div>
        <div class="flex items-center font-bold text-xs">
          <div class="border flex flex-col py-2 w-40">
            <div class="col-span-2 text-center">S. Name</div>
            <div class="col-span-2 text-sm font-normal text-center text-white">random</div>
          </div>
          <%= for subject <- @class.subjects, !String.ends_with?(subject.name, "_t") do %>
            <div class="border flex flex-col py-2 grow basis-24">
              <div class="col-span-2 text-center"><%= subject.name %></div>
              <div class="col-span-2 text-sm font-normal text-center">
                <%= get_total_marks_of_term_from_results(subject.classresults, @term_name) %>
              </div>
            </div>
          <% end %>
        </div>
        <%= for student <- @class.students do %>
          <div class="flex items-center text-xs">
            <div class="border pl-2 py-1 w-40">
              <%= student.name %>
            </div>
            <%= for subject <- student.subjects, !String.ends_with?(subject.name, "_t") do %>
              <div class="flex border justify-center py-1 grow basis-24">
                <%= get_obtained_marks_of_term_from_results(subject.results, @term_name) %>
              </div>
            <% end %>
          </div>
        <% end %>

        <div class="mb-2 mt-5 font-bold">Personality Traits</div>
        <div class="flex items-center font-bold text-xs">
          <div class="border flex flex-col py-2 w-40">
            <div class="col-span-2 text-center">S. Name</div>
            <div class="col-span-2 text-sm font-normal text-center text-white">random</div>
          </div>
          <%= for subject <- @class.subjects, String.ends_with?(subject.name, "_t") do %>
            <div class="border flex flex-col py-2 grow basis-24">
              <div class="col-span-2 text-center"><%= subject.name |> String.slice(0..-3) %></div>
              <div class="col-span-2 text-sm font-normal text-center">
                <%= get_total_marks_of_term_from_results(subject.classresults, @term_name) %>
              </div>
            </div>
          <% end %>
        </div>
        <%= for student <- @class.students do %>
          <div class="flex items-center text-xs">
            <div class="border pl-2 py-1 w-40">
              <%= student.name %>
            </div>
            <%= for subject <- student.subjects, String.ends_with?(subject.name, "_t") do %>
              <div class="flex border justify-center py-1 grow basis-24">
                <%= get_obtained_marks_of_term_from_results(subject.results, @term_name) %>
              </div>
            <% end %>
          </div>
        <% end %>

      </div>
    """
  end
end
