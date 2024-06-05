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
    """
  end
end
