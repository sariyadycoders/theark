defmodule TheArkWeb.StudentAttendanceLive do
  use TheArkWeb, :live_view

  alias TheArk.Students
  alias TheArk.Attendances
  alias TheArk.Offdays

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
        <div class="grid grid-cols-11 items-center border-b-4 pb-2 font-bold text-md">
          <div class="">Month</div>
          <div class="">Absents</div>
          <div class="col-span-2">Absent Days</div>
          <div class="">Leaves</div>
          <div class="col-span-2">Leave Days</div>
          <div class="">Half Leaves</div>
          <div class="col-span-2">H.Leave Days</div>
          <div class="">Present Days</div>
        </div>
        <%= for {year, attendances} <- @attendances do %>
          <div class="mt-2 font-bold text-lg"><%= year %></div>
          <%= for attendance <- attendances do %>
            <div class="grid grid-cols-11 items-center py-3 text-sm ml-2">
              <div class="">
                <%= attendance.month_number |> Timex.month_name() %> (<%= working_days_in_month(
                  attendance.month_number,
                  attendance.year
                ) %>/<%= total_days_in_month(attendance.month_number) %>)
              </div>
              <div class="ml-5"><%= attendance.number_of_absents %></div>
              <div class="col-span-2">
                <% count = Enum.count(attendance.absent_days) %>
                <%= for {day, index} <- Enum.with_index(attendance.absent_days) do %>
                  <span class={"px-2 #{if index < count - 1, do: "border-r-2"}"}>
                    <%= day.day |> to_string() %>
                  </span>
                <% end %>
              </div>
              <div class="ml-4"><%= attendance.number_of_leaves %></div>
              <div class="col-span-2">
                <% count = Enum.count(attendance.leave_days) %>
                <%= for {day, index} <- Enum.with_index(attendance.leave_days) do %>
                  <span class={"px-2 #{if index < count - 1, do: "border-r-2"}"}>
                    <%= day.day |> to_string() %>
                  </span>
                <% end %>
              </div>
              <div class="ml-8"><%= attendance.number_of_half_leaves %></div>
              <div class="col-span-2">
                <% count = Enum.count(attendance.half_leave_days) %>
                <%= for {day, index} <- Enum.with_index(attendance.half_leave_days) do %>
                  <span class={"px-2 #{if index < count - 1, do: "border-r-2"}"}>
                    <%= day.day |> to_string() %>
                  </span>
                <% end %>
              </div>
              <div class="flex justify-between">
                <div><%= attendance.number_of_presents %></div>
                <div class={"rounded-full w-4 h-4 #{if determine_attendance_completion(attendance) == "no", do: "bg-red-600", else: "bg-green-600"}"}>
                </div>
              </div>
            </div>
            <hr />
          <% end %>
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

  def determine_attendance_completion(attendance) do
    days_in_month = total_days_in_month(attendance.month_number)

    off_days =
      Offdays.get_offday_by_month_number(attendance.month_number, attendance.year, "students")

    off_days = if off_days, do: off_days.days, else: []

    total_marked_days =
      attendance.number_of_half_leaves + attendance.number_of_leaves +
        attendance.number_of_absents + attendance.number_of_presents

    days_should_be_marked = days_in_month - Enum.count(off_days)

    if total_marked_days < days_should_be_marked do
      "no"
    else
      "yes"
    end
  end

  def working_days_in_month(month_number, year) do
    off_days = Offdays.get_offday_by_month_number(month_number, year, "students")

    off_days = if off_days, do: off_days.days, else: []

    total_days_in_month(month_number) -
      Enum.count(off_days)
  end
end
