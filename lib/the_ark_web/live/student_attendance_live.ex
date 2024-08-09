defmodule TheArkWeb.StudentAttendanceLive do
  use TheArkWeb, :live_view

  alias TheArk.Students
  alias TheArk.Attendances
  alias TheArk.Offdays

  alias TheArkWeb.SharedLive

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    student_id = String.to_integer(id)

    attendances =
      Attendances.get_student_monthly_attendances_to_show(student_id)
      |> Enum.group_by(& &1.year)
      |> Enum.sort(:desc)
      |> Enum.map(fn {year, attendances} ->
        attendances = Enum.sort(attendances, &(&1.month_number > &2.month_number))

        {year, attendances}
      end)

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
        <SharedLive.student_attendance_heading assigns={assigns} />
        <%= for {year, attendances} <- @attendances do %>
          <div class="mt-2 font-bold text-lg"><%= year %></div>
          <SharedLive.student_attendance_table attendances={attendances} />
        <% end %>
      </div>
      <div class="grid grid-cols-11 items-center py-3 mt-10 text-lg font-bold border-b border-t fixed bottom-5 left-0 right-24 bg-sky-200 w-full pl-24">
        <div class="">Total</div>
        <div class="col-span-3 pl-4"><%= calculate_total(@attendances, "Absent") %></div>
        <div class="col-span-3 pl-5"><%= calculate_total(@attendances, "Leave") %></div>
        <div class="col-span-3 pl-10"><%= calculate_total(@attendances, "Half Leave") %></div>
      </div>
    </div>
    """
  end

  def calculate_total(attendances, "Absent") do
    Enum.map(attendances, fn {_year, attendances} ->
      Enum.map(attendances, fn attendance ->
        attendance.number_of_absents
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def calculate_total(attendances, "Leave") do
    Enum.map(attendances, fn {_year, attendances} ->
      Enum.map(attendances, fn attendance ->
        attendance.number_of_leaves
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def calculate_total(attendances, "Half Leave") do
    Enum.map(attendances, fn {_year, attendances} ->
      Enum.map(attendances, fn attendance ->
        attendance.number_of_half_leaves
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end
end
