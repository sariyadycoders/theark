defmodule TheArkWeb.StudentIndexLive do
  use TheArkWeb, :live_view

  alias TheArk.Students

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(active_students_count: Students.get_active_students_count())
    |> assign(total_students_count: Students.get_students_count())
    |> assign(students: Students.list_students_for_index())
    |> ok
  end

  @impl true
  def handle_event("show_student", %{"student_id" => id}, socket) do
    socket
    |> redirect(to: ~p"/students/#{id}")
    |> noreply
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center gap-5">
        <h1 class="font-bold text-3xl mb-5">The Ark Students</h1>
        <div class="ml-auto">
          Total Students Listed: <b><%= @total_students_count %></b>
        </div>
        <div>
          Total Active Students: <b><%= @active_students_count %></b>
        </div>
      </div>
      <div class="grid grid-cols-6 items-center border-b-4 pb-2 font-bold text-lg mb-2">
        <div>
          Name
        </div>
        <div>
          Father's Name
        </div>
        <div>
          Address
        </div>
        <div>
          Age
        </div>
        <div>
          Class
        </div>
        <div class="">
          Contact
        </div>
      </div>
      <%= for student <- @students do %>
        <div
          phx-click="show_student"
          phx-value-student_id={student.id}
          class="grid grid-cols-6 items-center border-b mb-2 cursor-pointer"
        >
          <div class="">
            <div class="flex items-center">
              <a><%= student.name %></a>
              <span
                :if={student.is_leaving}
                class="ml-2 text-xs p-0.5 px-1 border bg-red-200 rounded-lg"
              >
                non-active
              </span>
            </div>
          </div>
          <div>
            <%= student.father_name %>
          </div>
          <div>
            <%= student.address %>
          </div>
          <div>
            <%= calculate_age(student.date_of_birth) %>
          </div>
          <div>
            <%= student.class.name %>
          </div>
          <div class="">
            <div><b>W: </b><%= student.whatsapp_number %></div>
            <div><b>S: </b><%= student.sim_number %></div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def calculate_age(date_of_birth) do
    days_till_birth = Date.diff(Date.utc_today(), date_of_birth)
    (days_till_birth / 365) |> round()
  end
end
