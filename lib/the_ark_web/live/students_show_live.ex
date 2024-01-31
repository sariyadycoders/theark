defmodule TheArkWeb.StudentsShowLive do
  use TheArkWeb, :live_view

  alias TheArk.Students

  @impl true
  def mount(%{"id" => id}, _, socket) do
    socket
    |> assign(student: Students.get_student!(String.to_integer(id)))
    |> ok
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        <h1 class="font-bold text-3xl mb-5"><%= @student.name %></h1>
        <div class="grid grid-cols-5 items-center border-b-4 pb-2 font-bold text-lg mb-2">
          <div>
            Subject Name
          </div>
          <div>
            1st Term Total Marks
          </div>
          <div>
            1st Term Obtained Marks
          </div>
        </div>
        <%= for subject <- @student.subjects do %>
          <div class="grid grid-cols-5">
            <div>
              <%= subject.name %>
            </div>
            <div>
              <%= (Enum.filter(subject.results, fn result -> result.name == "first term" end) |> Enum.at(0)).total_marks  %>
            </div>
            <div>
              <%= (Enum.filter(subject.results, fn result -> result.name == "first term" end) |> Enum.at(0)).obtained_marks  %>
            </div>
          </div>

        <% end %>
      </div>
    """
  end







end
