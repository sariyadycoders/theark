defmodule TheArkWeb.StudentLive do
  use TheArkWeb, :live_view

  alias TheArk.{Classes, Students}

  @impl true
  def mount(%{"id" => id}, _, socket) do
    class = Classes.get_class!(String.to_integer(id))

    socket
    |> assign(class: class)
    |> assign(students: Students.get_students_by_class_id(id))
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
          Results
        </div>
      </div>
      <%= for student <- @students do %>
        <div class="grid grid-cols-6 items-center pb-2">
          <div>
            <%= student.name %>
          </div>
          <div>
            <%= student.father_name %>
          </div>
          <div>
            <%!-- <%= student.age %> --%>
          </div>
          <div class="col-span-3">
            <%= for subject <- student.subjects do %>
              <%= subject.name %>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
