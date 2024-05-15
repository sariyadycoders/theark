defmodule TheArkWeb.StudentAttendanceLive do
  alias TheArk.Students
  alias TheArk.Attendances
  use TheArkWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    student_id = String.to_integer(id)
    attendances = Attendances.get_student_monthly_attendance_to_show(student_id)
    student = Students.get_student_only(student_id)

    IO.inspect(attendances)

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
          <h1 class="font-bold text-3xl mb-5">Attendance Summary for  <%= @student.name %> of Class <%= @student.class.name %></h1>
        </div>
        <div class="grid grid-cols-10 border-2 font-bold">
          <div class="border p-2">Month</div>
          <div class="border p-2">Absents</div>
          <div class="col-span-2 border p-2">Absent Days</div>
          <div class="border p-2">Leaves</div>
          <div class="col-span-2 border p-2">Leave Days</div>
          <div class="border p-2">Half Leaves</div>
          <div class="col-span-2 border p-2">H.Leave Days</div>
        </div>
      </div>
    """
  end
end
