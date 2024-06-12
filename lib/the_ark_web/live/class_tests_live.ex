defmodule TheArkWeb.ClassTestsLive do
  alias TheArk.Classes
  use TheArkWeb, :live_view

  @impl true
  def mount(%{"id" => class_id}, _session, socket) do
    class = Classes.get_class_for_tests_page(String.to_integer(class_id))

    socket
    |> assign(class: class)
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between mb-5">
        <h1 class="font-bold text-3xl mb-5">Tests List for Class <%= @class.name %></h1>
      </div>
      <div class="grid grid-cols-7 items-center border-b-4 pb-2 font-bold text-md">
        <div>
          Subject
        </div>
        <div>
          Date
        </div>
        <div>
          Total Marks
        </div>
        <div>
          Failed Students
        </div>
        <div class="">
          Average Result
        </div>
        <div class="col-span-2">
          Actions
        </div>
      </div>
      <%= for test <- @class.tests do %>
        <div class="grid grid-cols-7 items-center py-3 text-sm">
          <div>
            <%= test.subject %>
          </div>
          <div>
            <%= test.date_of_test %>
          </div>
          <div>
            <%= test.total_marks %>
          </div>
          <div>
            Failed Students
          </div>
          <div class="">
            Average Result
          </div>
          <div class=""></div>
          <div>
            Actions
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
