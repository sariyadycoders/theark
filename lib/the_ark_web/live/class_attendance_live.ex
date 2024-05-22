defmodule TheArkWeb.ClassAttendanceLive do
  use TheArkWeb, :live_view

  alias TheArk.{
    Classes,
    Attendances,
    Attendances.Attendance,
    Students,
    Finances,
    Finances.Finance
  }

  alias Phoenix.LiveView.Components.MultiSelect

  @absent_fine 100

  @impl true
  def mount(%{"id" => class_id}, _, socket) do
    student_options = Students.get_student_options_for_attendance(String.to_integer(class_id))

    socket
    |> assign(student_options: student_options)
    |> assign(attendance_changeset: Attendances.change_attendance(%Attendance{}))
    |> assign(edit_attendance_id: 0)
    |> assign(absent_fine: @absent_fine)
    |> assign(class_id: String.to_integer(class_id))
    |> assign(add_attendance_date: nil)
    |> assign(selected_month: Timex.month_name(Date.utc_today().month))
    |> assign(selected_month_number: Date.utc_today().month)
    |> assign(current_month_number: Date.utc_today().month)
    |> assign(month_options: month_options())
    |> assign_class_for_attendance()
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
    if String.starts_with?(id, "a") do
      socket
      |> assign(attendance_changeset: Attendances.change_attendance(%Attendance{}))
      |> assign(edit_attendance_id: 0)
      |> put_flash(:error, "Attendance not available!")
      |> noreply()
    else
      attendance = Attendances.get_attendance!(id)
      changeset = Attendances.change_attendance(attendance, %{})

      socket
      |> assign(attendance_changeset: changeset)
      |> assign(edit_attendance_id: String.to_integer(id))
      |> noreply()
    end
  end

  @impl true
  def handle_event(
        "update_attendance",
        %{"attendance" => params},
        %{
          assigns: %{
            edit_attendance_id: edit_attendance_id,
            class_id: _class_id,
            absent_fine: absent_fine
          }
        } = socket
      ) do
    prev_attendance = Attendances.get_attendance!(edit_attendance_id)

    {:ok, new_attendance} = Attendances.update_attendance(prev_attendance, params)

    if prev_attendance.entry == "Absent" and new_attendance.entry != "Absent" do
      group_id = Students.get_group_id_only(new_attendance.student_id)
      Finances.delete_absent_fine(prev_attendance.date, group_id)
    end

    if prev_attendance.entry != "Absent" and new_attendance.entry == "Absent" do
      group_id = Students.get_group_id_only(new_attendance.student_id)

      Finances.change_finance(%Finance{}, %{
        group_id: group_id,
        absent_fine_date: new_attendance.date,
        absent_student_name: Students.get_student_name(new_attendance.student_id),
        transaction_details: [
          %{
            title: "Absent Fine",
            total_amount: absent_fine,
            paid_amount: 0,
            absent_fine_date: new_attendance.date
          }
        ]
      })
      |> Finances.create_finance()
    end

    socket
    |> assign_class_for_attendance()
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
            class_id: class_id,
            absent_fine: absent_fine
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
          prev_attendance = Attendances.get_one_attendance(id, date)
          Attendances.update_attendance(prev_attendance, %{entry: "Absent"})
          group_id = Students.get_group_id_only(id)

          if prev_attendance.entry != "Absent" do
            Finances.change_finance(%Finance{}, %{
              group_id: group_id,
              absent_fine_date: date,
              absent_student_name: Students.get_student_name(id),
              transaction_details: [
                %{
                  title: "Absent Fine",
                  total_amount: absent_fine,
                  paid_amount: 0,
                  absent_fine_date: date
                }
              ]
            })
            |> Finances.create_finance()
          end
        end

        for id <- present_student_ids do
          prev_attendance = Attendances.get_one_attendance(id, date)

          {:ok, new_attendance} =
            Attendances.update_attendance(prev_attendance, %{entry: "Present"})

          if prev_attendance.entry == "Absent" do
            group_id = Students.get_group_id_only(new_attendance.student_id)
            Finances.delete_absent_fine(prev_attendance.date, group_id)
          end
        end

        student_options = Students.get_student_options_for_attendance(class_id)

        socket
        |> put_flash(:info, "Attendance successfully added!")
        |> assign(add_attendance_date: nil)
        |> assign(student_options: student_options)
        |> assign_class_for_attendance()
        |> noreply()
    end
  end

  @impl true
  def handle_event("selected_month", %{"selected_month" => %{"month" => month_number}}, socket) do
    month_number = String.to_integer(month_number)
    selected_month = Timex.month_name(month_number)

    socket
    |> assign(selected_month: selected_month)
    |> assign(selected_month_number: month_number)
    |> assign_class_for_attendance()
    |> noreply()
  end

  @impl true
  def handle_event("to_student_attendance", %{"id" => id}, socket) do
    socket
    |> redirect(to: "/students/#{String.to_integer(id)}/attendance")
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between">
        <h1 class="font-bold text-3xl mb-5">Attendance for Class <%= @class.name %></h1>
        <div class="flex items-end gap-2">
          <.button phx-click={show_modal("add_attendance")}>Add Attendance</.button>
          <div>
            <.form :let={f} for={} as={:selected_month} phx-change="selected_month">
              <.input
                field={f[:month]}
                label="Month"
                type="select"
                options={@month_options}
                value={@selected_month_number}
              />
            </.form>
          </div>
        </div>
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
        <%= for day_number <- 1..month_days(@selected_month) do %>
          <% day_name = get_name_of_day(day_number, @selected_month) %>
          <div class={"border px-0.5 py-1 w-9 h-16 text-center #{if day_name == "Su", do: "bg-yellow-400"}"}>
            <div><%= day_number %></div>
            <div class="mt-1"><%= day_name %></div>
          </div>
        <% end %>
      </div>
      <%= for student <- @class.students do %>
        <div class="flex items-center justify-between">
          <div
            phx-click="to_student_attendance"
            phx-value-id={student.id}
            class="border px-2 w-40 h-9 py-1"
          >
            <%= student.name %>
          </div>
          <%= for day_number <- 1..month_days(@selected_month) do %>
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

  def get_name_of_day(day_number, selected_month) do
    day_of_week =
      first_date_of_month(selected_month)
      |> Date.add(day_number - 1)
      |> Date.day_of_week()

    Timex.day_shortname(day_of_week)
    |> String.slice(0, 2)
  end

  def month_days(selected_month) do
    Timex.days_in_month(first_date_of_month(selected_month))
  end

  def get_attendance(student, day_number) do
    attendance =
      Enum.filter(student.attendances, fn attn ->
        attn.date.day == day_number
      end)
      |> Enum.at(0)

    if attendance do
      case attendance.entry do
        "Not Marked Yet" -> ""
        "Present" -> "P"
        "Leave" -> "L"
        "Half Leave" -> "H"
        "Absent" -> "A"
      end
    else
      "N"
    end
  end

  def get_attendance_id(student, day_number) do
    attendance =
      Enum.filter(student.attendances, fn attn ->
        attn.date.day == day_number
      end)
      |> Enum.at(0)

    if attendance do
      attendance.id
    else
      "a#{student.id}#{day_number}"
    end
  end

  def get_attendance_entry(student, day_number) do
    attendance =
      Enum.filter(student.attendances, fn attn ->
        attn.date.day == day_number
      end)
      |> Enum.at(0)

    if attendance do
      attendance.entry
    else
      "N"
    end
  end

  def month_options() do
    current_month_no = Date.utc_today().month

    prev_one_month =
      if current_month_no - 1 > 0 do
        current_month_no - 1
      else
        12
      end

    prev_two_month =
      if current_month_no - 2 > 0 do
        current_month_no - 2
      else
        case current_month_no - 2 do
          0 -> 12
          -1 -> 11
        end
      end

    next_month =
      if current_month_no == 12 do
        1
      else
        current_month_no + 1
      end

    [
      "#{Timex.month_name(prev_two_month)}": prev_two_month,
      "#{Timex.month_name(prev_one_month)}": prev_one_month,
      "#{Timex.month_name(current_month_no)}": current_month_no,
      "#{Timex.month_name(next_month)}": next_month
    ]
  end

  def assign_class_for_attendance(
        %{assigns: %{class_id: class_id, selected_month: selected_month}} = socket
      ) do
    first_date_of_month = first_date_of_month(selected_month)
    days_in_month = Timex.days_in_month(first_date_of_month)

    list_of_dates =
      Enum.map(1..days_in_month, fn num ->
        Date.add(first_date_of_month, num - 1)
      end)

    class = Classes.get_class_for_attendance!(class_id, list_of_dates)

    socket
    |> assign(class: class)
  end

  def prev_month_calculation() do
    case Date.utc_today().month - 1 do
      0 -> 12
      _ -> Date.utc_today().month - 1
    end
  end
end
