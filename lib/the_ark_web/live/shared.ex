defmodule TheArkWeb.SharedLive do
  use TheArkWeb, :live_view

  def student_attendance_heading(assigns) do
    ~H"""
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
    """
  end

  def student_attendance_table(assigns) do
    ~H"""
    <%= for attendance <- @attendances do %>
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
    """
  end
end
