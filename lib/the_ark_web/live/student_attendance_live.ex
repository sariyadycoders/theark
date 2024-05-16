defmodule TheArkWeb.StudentAttendanceLive do
  alias TheArk.Students
  alias TheArk.Attendances
  use TheArkWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    student_id = String.to_integer(id)
    attendances = Attendances.get_student_monthly_attendances_to_show(student_id)
    student = Students.get_student_only(student_id)

    socket
    |> assign(attendances: attendances)
    |> assign(student: student)
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between">
        <h1 class="font-bold text-3xl mb-5">
          Attendance Summary for <%= @student.name %> of Class <%= @student.class.name %>
        </h1>
      </div>
      <div class="mb-40">
        <div class="grid grid-cols-10 items-center border-b-4 pb-2 font-bold text-md">
          <div class="">Month</div>
          <div class="">Absents</div>
          <div class="col-span-2">Absent Days</div>
          <div class="">Leaves</div>
          <div class="col-span-2">Leave Days</div>
          <div class="">Half Leaves</div>
          <div class="col-span-2">H.Leave Days</div>
        </div>
        <%= for attendance <- @attendances do %>
          <div class="grid grid-cols-10 items-center py-3 text-sm">
            <div class=""><%= attendance.month_number |> Timex.month_name() %></div>
            <div class=""><%= attendance.number_of_absents %></div>
            <div class="col-span-2">
              <%= for day <- attendance.absent_days, do: day |> Date.to_string() %>
            </div>
            <div class=""><%= attendance.number_of_leaves %></div>
            <div class="col-span-2">
              <%= for day <- attendance.leave_days, do: day |> Date.to_string() %>
            </div>
            <div class=""><%= attendance.number_of_half_leaves %></div>
            <div class="col-span-2">
              <%= for day <- attendance.half_leave_days, do: day |> Date.to_string() %>
            </div>
          </div>
          <hr />
        <% end %>
      </div>
      <div class="grid grid-cols-10 items-center py-3 mt-10 text-lg font-bold border-b border-t fixed bottom-5 left-24 right-24 bg-white">
        <div class="">Total</div>
        <div class="col-span-3"><%= calculate_total(@attendances, "Absent") %></div>
        <div class="col-span-3"><%= calculate_total(@attendances, "Leave") %></div>
        <div class="col-span-3"><%= calculate_total(@attendances, "Half Leave") %></div>
      </div>
    </div>
    """
  end

  def calculate_total(attendances, "Absent") do
    Enum.map(attendances, fn attendance ->
      attendance.number_of_absents
    end)
    |> Enum.sum()
  end

  def calculate_total(attendances, "Leave") do
    Enum.map(attendances, fn attendance ->
      attendance.number_of_leaves
    end)
    |> Enum.sum()
  end

  def calculate_total(attendances, "Half Leave") do
    Enum.map(attendances, fn attendance ->
      attendance.number_of_half_leaves
    end)
    |> Enum.sum()
  end
end
