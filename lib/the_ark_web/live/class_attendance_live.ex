defmodule TheArkWeb.ClassAttendanceLive do
  use TheArkWeb, :live_view

  alias TheArk.{
    Classes
  }

  @impl true
  def mount(%{"id" => class_id}, _, socket) do
    class = Classes.get_class_for_attendance!(class_id)

    socket
    |> assign(class: class)
    |> ok
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        <div class="flex items-center justify-between">
          <h1 class="font-bold text-3xl mb-5">Attendance for Class <%= @class.name %></h1>
          <.button phx-click="go_to_registration">Add Attendance</.button>
        </div>
        <div class="font-bold flex items-center justify-between mt-5">
          <div class="border px-2 w-40 h-9 py-1">
            Student Name
          </div>
          <%= for date <- 1..current_month_days() do %>
            <div class="border px-0.5 py-1 w-9 h-9 text-center">
              <%= date %>
            </div>
          <% end %>
        </div>
        <%= for student <- @class.students do %>
          <div class="flex items-center justify-between">
            <div class="border px-2 w-40 h-9 py-1">
              <%= student.name %>
            </div>
            <%= for day_number <- 1..current_month_days() do %>
              <div class="border px-0.5 py-1 w-9 h-9 text-center">
                <%= get_attendence(student, day_number) %>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    """
  end

  def current_month_days() do
    Timex.days_in_month(Date.utc_today())
  end

  def get_attendence(student, day_number) do
    attendance =
      Enum.filter(student.attendances, fn attn ->
        attn.date.day == day_number
      end)
      |> Enum.at(0)

    case attendance.entry do
      "M" -> "i"
      _ -> attendance.entry
    end
  end

end
