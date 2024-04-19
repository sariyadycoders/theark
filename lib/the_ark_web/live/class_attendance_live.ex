defmodule TheArkWeb.ClassAttendanceLive do
  use TheArkWeb, :live_view

  alias TheArk.{
    Classes,
    Attendances,
    Attendances.Attendance,
    Students
  }

  alias Phoenix.LiveView.Components.MultiSelect

  @impl true
  def mount(%{"id" => class_id}, _, socket) do
    class = Classes.get_class_for_attendance!(class_id)
    student_options = Students.get_student_options_for_attendance(String.to_integer(class_id))

    socket
    |> assign(class: class)
    |> assign(student_options: student_options)
    |> assign(attendance_changeset: Attendances.change_attendance(%Attendance{}))
    |> assign(edit_attendance_id: 0)
    |> assign(class_id: String.to_integer(class_id))
    |> assign(add_attendance_date: nil)
    |> ok
  end

  @impl true
  def handle_info({:updated_options, options}, socket) do
    socket
    |> assign(student_options: options)
    |> noreply()
  end

  @impl true
  def handle_event("make_attendance_changeset", %{"attendance_id" => id}, socket) do
    attendance = Attendances.get_attendance!(id)
    changeset = Attendances.change_attendance(attendance, %{})

    socket
    |> assign(attendance_changeset: changeset)
    |> assign(edit_attendance_id: String.to_integer(id))
    |> noreply()
  end

  @impl true
  def handle_event(
        "update_attendance",
        %{"attendance" => params},
        %{assigns: %{edit_attendance_id: edit_attendance_id, class_id: class_id}} = socket
      ) do
    attendance = Attendances.get_attendance!(edit_attendance_id)

    {:ok, _} = Attendances.update_attendance(attendance, params)
    class = Classes.get_class_for_attendance!(class_id)

    socket
    |> assign(class: class)
    |> noreply()
  end

  @impl true
  def handle_event("validate", %{"attendance" => %{"date" => date}}, socket) do
    socket
    |> assign(add_attendance_date: date)
    |> noreply()
  end

  @impl true
  def handle_event(
        "add_attendance",
        _params,
        %{
          assigns: %{
            student_options: student_options,
            add_attendance_date: add_attendance_date,
            class_id: class_id
          }
        } = socket
      ) do
    case add_attendance_date do
      nil ->
        socket
        |> put_flash(:error, "Choose date of attendance!")
        |> noreply()

      "" ->
        socket
        |> put_flash(:error, "Choose date of attendance!")
        |> noreply()

      _ ->
        {:ok, date} = Date.from_iso8601(add_attendance_date)

        absent_student_ids =
          Enum.filter(student_options, fn option ->
            option.selected
          end)
          |> Enum.map(fn student ->
            student.id
          end)

        present_student_ids =
          Enum.filter(student_options, fn option ->
            !option.selected
          end)
          |> Enum.map(fn student ->
            student.id
          end)

        for id <- absent_student_ids do
          attendance = Attendances.get_one_attendance(id, date)
          Attendances.update_attendance(attendance, %{entry: "Absent"})
        end

        for id <- present_student_ids do
          attendance = Attendances.get_one_attendance(id, date)
          Attendances.update_attendance(attendance, %{entry: "Present"})
        end

        class = Classes.get_class_for_attendance!(class_id)
        student_options = Students.get_student_options_for_attendance(class_id)

        socket
        |> put_flash(:info, "Attendance successfully added!")
        |> assign(add_attendance_date: nil)
        |> assign(class: class)
        |> assign(student_options: student_options)
        |> noreply()
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between">
        <h1 class="font-bold text-3xl mb-5">Attendance for Class <%= @class.name %></h1>
        <.button phx-click={show_modal("add_attendance")}>Add Attendance</.button>
      </div>
      <.modal id="add_attendance">
        <.form :let={f} for={} as={:attendance} phx-submit="add_attendance" phx-change="validate">
          <.input field={f[:date]} label="Date of attendance" type="date" />
          <MultiSelect.multi_select
            id={"students_#{@class.id}"}
            on_change={fn opts -> send(self(), {:updated_options, opts}) end}
            form={f}
            options={@student_options}
            placeholder="Select Absent Students..."
            title="Select Absent Students"
          />
          <.button class="mt-10">Submit</.button>
        </.form>
      </.modal>
      <div class="font-bold flex items-center justify-between mt-5">
        <div class="border px-2 flex items-center w-40 h-16 py-1">
          <div>Student Name</div>
        </div>
        <%= for day_number <- 1..current_month_days() do %>
          <% day_name = get_name_of_day(day_number) %>
          <div class={"border px-0.5 py-1 w-9 h-16 text-center #{if day_name == "Su", do: "bg-yellow-400"}"}>
            <div><%= day_number %></div>
            <div class="mt-1"><%= day_name %></div>
          </div>
        <% end %>
      </div>
      <%= for student <- @class.students do %>
        <div class="flex items-center justify-between">
          <div class="border px-2 w-40 h-9 py-1">
            <%= student.name %>
          </div>
          <%= for day_number <- 1..current_month_days() do %>
            <% id = get_attendance_id(student, day_number) %>
            <% entry = get_attendance_entry(student, day_number) %>
            <div
              phx-click={JS.push("make_attendance_changeset") |> show_modal("edit_attendance_#{id}")}
              phx-value-attendance_id={id}
              class={[
                "border px-0.5 py-1 w-9 h-9 text-center font-bold",
                "#{if entry == "Present", do: "bg-green-300"}",
                "#{if entry == "Absent", do: "bg-red-300"}",
                "#{if entry == "Leave", do: "bg-blue-300"}",
                "#{if entry == "Half Leave", do: "bg-violet-300"}",
                "#{if entry == "Not Marked Yet", do: "bg-yellow-400"}"
              ]}
            >
              <%= get_attendance(student, day_number) %>
            </div>

            <.modal id={"edit_attendance_#{id}"}>
              <%= if @edit_attendance_id == id do %>
                <.form :let={f} for={@attendance_changeset} phx-submit="update_attendance">
                  <.input
                    field={f[:entry]}
                    label="Type"
                    type="select"
                    options={["Present", "Leave", "Half Leave", "Absent", "Not Marked Yet"]}
                  />
                  <.button class="mt-5">Submit</.button>
                </.form>
              <% end %>
            </.modal>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  def get_name_of_day(day_number) do
    day_of_week =
      Timex.beginning_of_month(Date.utc_today())
      |> Date.add(day_number - 1)
      |> Date.day_of_week()

    Timex.day_shortname(day_of_week)
    |> String.slice(0, 2)
  end

  def current_month_days() do
    Timex.days_in_month(Date.utc_today())
  end

  def get_attendance(student, day_number) do
    attendance =
      Enum.filter(student.attendances, fn attn ->
        attn.date.day == day_number
      end)
      |> Enum.at(0)

    case attendance.entry do
      "Not Marked Yet" -> ""
      "Present" -> "P"
      "Leave" -> "L"
      "Half Leave" -> "H"
      "Absent" -> "A"
    end
  end

  def get_attendance_id(student, day_number) do
    (Enum.filter(student.attendances, fn attn ->
       attn.date.day == day_number
     end)
     |> Enum.at(0)).id
  end

  def get_attendance_entry(student, day_number) do
    (Enum.filter(student.attendances, fn attn ->
       attn.date.day == day_number
     end)
     |> Enum.at(0)).entry
  end
end
