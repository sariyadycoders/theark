defmodule TheArkWeb.Home do
  use TheArkWeb, :live_view
  # progress graphs system
  # teachers attendance and salary system

  import Phoenix.HTML.Form

  alias TheArk.{
    Classes,
    Classes.Class,
    Students,
    Students.Student,
    Teachers,
    Teachers.Teacher,
    Subjects,
    Serials,
    Organizations,
    Roles.Role,
    Roles,
    Attendances,
    Subjects,
    Tests,
    Tests.Test,
    Offdays,
    Offdays.Offday
  }

  # import Ecto.Changeset
  alias Phoenix.LiveView.Components.MultiSelect

  @month_options [
    {"None", 0},
    {"January", 1},
    {"February", 2},
    {"March", 3},
    {"April", 4},
    {"May", 5},
    {"June", 6},
    {"July", 7},
    {"August", 8},
    {"September", 9},
    {"October", 10},
    {"November", 11},
    {"December", 12}
  ]

  @days_of_week ~w(Mon Tue Wed Thu Fri Sat Sun)

  @impl true
  def mount(_, _, socket) do
    organization = Organizations.get_organization_by_name("the_ark")

    socket
    |> assign(classes: Classes.list_classes())
    |> assign(teachers: Teachers.list_teachers())
    |> assign(class_changeset: Classes.change_class(%Class{}))
    |> assign(student_changeset: Students.change_student(%Student{}))
    |> assign(teacher_changeset: Teachers.change_teacher(%Teacher{}))
    |> assign(
      off_days_changeset: Offdays.change_offday(%Offday{}, %{year: Date.utc_today().year})
    )
    |> assign(role_changeset: Roles.change_role(%Role{}))
    |> assign(test_changeset: Tests.change_class_test(%Test{}))
    |> assign(test_subject_options: [])
    |> assign(role_editing_id: 0)
    |> assign(organization_changeset: Organizations.change_organization(organization))
    |> assign(subject_options: Subjects.list_subject_options())
    |> assign(organization: organization)
    |> assign(students_list: nil)
    |> assign(current_month_number: Date.utc_today().month)
    |> assign(month_options: @month_options)
    |> assign(chosen_month_for_offdays_modal: nil)
    |> assign(days_of_week: @days_of_week)
    |> assign(open_modal_id: nil)
    |> assign(for_staff: false)
    |> assign(for_students: false)
    |> assign(is_end_of_year: false)
    |> assign(list_of_terms: Classes.make_list_of_terms())
    |> ok()
  end

  @impl true
  def handle_info({:updated_options, opts}, socket) do
    socket
    |> assign(subject_options: opts)
    |> noreply
  end

  @impl true
  def handle_event("class_validation", %{"class" => params}, socket) do
    class_changeset = Classes.change_class(%Class{}, params) |> Map.put(:action, :insert)

    socket
    |> assign(class_changeset: class_changeset)
    |> noreply()
  end

  @impl true
  def handle_event(
        "class_submission",
        %{"class" => class_params},
        %{assigns: %{subject_options: subject_options}} = socket
      ) do
    case Classes.create_class(class_params, subject_options) do
      {:ok, _class} ->
        socket
        |> assign(class_changeset: Classes.change_class(%Class{}))
        |> assign(classes: Classes.list_classes())
        |> assign(
          subject_options:
            Enum.map(subject_options, fn subject -> Map.delete(subject, :selected) end)
        )
        |> put_flash(:info, "Class is successfully created!")
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(class_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event("teacher_validation", %{"teacher" => params}, socket) do
    teacher_changeset = Teachers.change_teacher(%Teacher{}, params) |> Map.put(:action, :insert)

    socket
    |> assign(teacher_changeset: teacher_changeset)
    |> noreply()
  end

  @impl true
  def handle_event("teacher_submission", %{"teacher" => params}, socket) do
    registration_date = Date.utc_today()

    params =
      Map.merge(params, %{
        "registration_date" => registration_date
      })

    case Teachers.create_teacher(params) do
      {:ok, teacher} ->
        serial = Serials.get_serial_by_name("teacher")
        registration_number = generate_registration_number(serial.number)
        Serials.update_serial(serial, %{"number" => registration_number})

        Teachers.update_teacher(teacher, %{"registration_number" => registration_number})

        socket
        |> put_flash(:info, "Teacher is successfully registered!")
        |> assign(teachers: Teachers.list_teachers())
        |> assign(teacher_changeset: Teachers.change_teacher(%Teacher{}))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(teacher_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event("student_validation", %{"student" => params}, socket) do
    student_changeset = Students.change_student(%Student{}, params) |> Map.put(:action, :insert)

    socket
    |> assign(student_changeset: student_changeset)
    |> noreply()
  end

  @impl true
  def handle_event("student_submission", %{"student" => params}, socket) do
    enrollment_date = Date.utc_today()
    class_of_enrollment = Classes.get_class_name(String.to_integer(params["class_id"]))

    params =
      Map.merge(params, %{
        "enrollment_date" => enrollment_date,
        "class_of_enrollment" => class_of_enrollment
      })

    case Students.create_student(params) do
      {:ok, student} ->
        serial = Serials.get_serial_by_name("student")
        enrollment_number = generate_registration_number(serial.number)
        Serials.update_serial(serial, %{"number" => enrollment_number})
        Students.update_student(student, %{"enrollment_number" => enrollment_number})

        socket
        |> put_flash(:info, "Student is successfully registered!")
        |> assign(student_changeset: Students.change_student(%Student{}))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(student_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event("terms_announcement", %{"term_name" => term_name}, socket) do
    Classes.term_announcement(term_name)

    socket
    |> assign(list_of_terms: Classes.make_list_of_terms())
    |> assign(is_end_of_year: false)
    |> noreply()
  end

  @impl true
  def handle_event(
        "update_organization",
        %{"organization" => org_params},
        %{assigns: %{organization: organization}} = socket
      ) do
    {:ok, organization} = Organizations.update_organization(organization, org_params)

    socket
    |> assign(organization: organization)
    |> put_flash(:info, "Stats updated!")
    |> noreply()
  end

  @impl true
  def handle_event("role_editing_id", %{"role_id" => id}, socket) do
    role = Roles.get_role!(id)

    socket
    |> assign(role_editing_id: role.id)
    |> assign(role_changeset: Roles.change_role(role))
    |> noreply()
  end

  @impl true
  def handle_event("edit_role", %{"role_id" => role_id, "role" => role_params}, socket) do
    role = Roles.get_role!(role_id)

    case Roles.update_role(role, role_params) do
      {:ok, _role} ->
        socket
        |> assign(role_changeset: Roles.change_role(%Role{}))
        |> assign(organization: Organizations.get_organization_by_name("the_ark"))
        |> put_flash(:info, "Designation updated succcessfully!")
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(role_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event(
        "seach_student",
        %{"seach_student" => %{"student_name" => student_name}},
        socket
      ) do
    students = Students.get_students_for_search_results(student_name)

    students =
      if students == [] or student_name == "" do
        nil
      else
        students
      end

    socket
    |> assign(students_list: students)
    |> noreply()
  end

  @impl true
  def handle_event("role_adding", %{"org_id" => org_id, "role" => role_params}, socket) do
    params = Map.merge(role_params, %{"organization_id" => org_id})

    case Roles.create_role(params) do
      {:ok, _role} ->
        socket
        |> put_flash(:info, "Role is created successfully!")
        |> assign(organization: Organizations.get_organization_by_name("the_ark"))
        |> assign(role_changeset: Roles.change_role(%Role{}))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(role_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event(
        "end_of_month",
        %{"end_of_month" => %{"month_number" => month_number}},
        socket
      ) do
    month_number = String.to_integer(month_number)

    if month_number > 0 do
      Attendances.create_monthly_attendances(month_number)

      socket
      |> assign(open_modal_id: nil)
      |> put_flash(:info, "Month ended successfully!")
      |> noreply()
    else
      socket
      |> put_flash(:error, "Choose month please!")
      |> noreply()
    end
  end

  @impl true
  def handle_event(
        "choose_fine_submission_class",
        %{"choose_class" => %{"class" => "0"}},
        socket
      ) do
    socket
    |> noreply()
  end

  @impl true
  def handle_event(
        "choose_fine_submission_class",
        %{"choose_class" => %{"class" => class_id}},
        socket
      ) do
    socket
    |> redirect(to: "/classes/#{String.to_integer(class_id)}/submit-fine")
    |> noreply()
  end

  @impl true
  def handle_event(
        "validate_test_init",
        %{
          "test" =>
            %{
              "class_id" => class_id,
              "total_marks" => _total_marks,
              "subject" => _subject,
              "date_of_test" => _date
            } = params
        },
        %{assigns: %{test_subject_options: test_subject_options}} = socket
      ) do
    class_id = String.to_integer(class_id)
    class_id = if class_id > 0, do: class_id, else: nil

    test_subject_options =
      if class_id do
        Subjects.get_subject_options_for_select(class_id)
        |> Enum.reject(fn {_key, value} ->
          String.ends_with?(value, "_t")
        end)
      else
        test_subject_options
      end

    params = Map.put(params, "class_id", class_id)

    test_changeset =
      Tests.change_class_test(%Test{}, params)
      |> Map.put(:action, :insert)

    socket
    |> assign(test_subject_options: test_subject_options)
    |> assign(test_changeset: test_changeset)
    |> noreply()
  end

  @impl true
  def handle_event(
        "validate_test_init",
        %{
          "test" =>
            %{
              "class_id" => class_id
            } = _params
        },
        %{assigns: %{test_subject_options: test_subject_options}} = socket
      ) do
    class_id = String.to_integer(class_id)
    class_id = if class_id > 0, do: class_id, else: nil

    test_subject_options =
      if class_id do
        Subjects.get_subject_options_for_select(class_id)
        |> Enum.reject(fn {_key, value} ->
          String.ends_with?(value, "_t")
        end)
      else
        test_subject_options
      end

    socket
    |> assign(test_subject_options: test_subject_options)
    |> noreply()
  end

  @impl true
  def handle_event(
        "submit_test_init",
        %{
          "test" =>
            %{
              "class_id" => class_id,
              "total_marks" => _total_marks,
              "subject" => _subject,
              "date_of_test" => _date
            } = params
        },
        socket
      ) do
    class_id = String.to_integer(class_id)
    class_id = if class_id > 0, do: class_id, else: nil

    params =
      Map.put(params, "class_id", class_id)
      |> Map.put("is_class_test", true)

    case Tests.create_class_test(params) do
      {:ok, _test} ->
        socket
        |> put_flash(:info, "Test initiated successfully!")
        |> assign(test_changeset: Tests.change_class_test(%Test{}))
        |> assign(test_subject_options: [])
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(test_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event(
        "validate_off_days",
        %{
          "_target" => ["offday", "month_number"],
          "offday" => %{
            "month_number" => month_number
          }
        },
        %{assigns: %{off_days_changeset: off_days_changeset, for_staff: for_staff}} = socket
      ) do
    month_number = String.to_integer(month_number)
    binding = if for_staff, do: "staff", else: "students"

    if month_number > 0 do
      off_day = Offdays.get_offday_by_month_number(month_number, Date.utc_today().year, binding)

      changeset =
        if off_day do
          Offdays.change_offday(off_day, %{})
          |> then(fn changeset ->
            if binding == "staff" do
              Ecto.Changeset.put_change(changeset, :for_staff, true)
            else
              Ecto.Changeset.put_change(changeset, :for_students, true)
            end
          end)
        else
          change = Ecto.Changeset.put_change(off_days_changeset, :month_number, month_number)

          Offdays.change_offday(%Offday{}, Map.put(change.changes, :year, Date.utc_today().year))
          |> then(fn changeset ->
            if binding == "staff" do
              Ecto.Changeset.put_change(changeset, :for_staff, true)
            else
              Ecto.Changeset.put_change(changeset, :for_students, true)
            end
          end)
          |> Ecto.Changeset.delete_change(:days)
        end

      socket
      |> assign(chosen_month_for_offdays_modal: month_number)
      |> assign(off_days_changeset: changeset)
      |> month_dates()
      |> noreply()
    else
      changeset = Ecto.Changeset.delete_change(off_days_changeset, :month_number)

      changeset = Offdays.change_offday(%Offday{}, changeset.changes)

      socket
      |> assign(off_days_changeset: changeset)
      |> assign(chosen_month_for_offdays_modal: nil)
      |> noreply()
    end
  end

  @impl true
  def handle_event(
        "validate_off_days",
        %{"_target" => coming_list},
        %{
          assigns: %{
            off_days_changeset: off_days_changeset,
            chosen_month_for_offdays_modal: month_number,
            for_staff: for_staff
          }
        } = socket
      ) do
    binding = if for_staff, do: "staff", else: "students"
    off_day = Offdays.get_offday_by_month_number(month_number, Date.utc_today().year, binding)
    coming_list = Enum.map(coming_list, &String.to_integer(&1))
    coming_value = hd(coming_list)
    already_list = Ecto.Changeset.get_field(off_days_changeset, :days)

    changeset =
      if already_list do
        final_list =
          if coming_value in already_list,
            do: already_list -- coming_list,
            else: already_list ++ coming_list

        final_list = if Enum.empty?(final_list), do: nil, else: final_list

        Ecto.Changeset.put_change(off_days_changeset, :days, final_list)
        |> then(fn changeset ->
          if binding == "staff" do
            Ecto.Changeset.put_change(changeset, :for_staff, true)
          else
            Ecto.Changeset.put_change(changeset, :for_students, true)
          end
        end)
      else
        Ecto.Changeset.put_change(off_days_changeset, :days, coming_list)
        |> then(fn changeset ->
          if binding == "staff" do
            Ecto.Changeset.put_change(changeset, :for_staff, true)
          else
            Ecto.Changeset.put_change(changeset, :for_students, true)
          end
        end)
      end

    changeset =
      if off_day do
        Offdays.change_offday(off_day, changeset.changes)
      else
        Offdays.change_offday(%Offday{}, changeset.changes)
      end

    socket
    |> assign(off_days_changeset: changeset)
    |> noreply()
  end

  def handle_event(
        "submit_off_days",
        _unsigned_params,
        %{assigns: %{off_days_changeset: off_days_changeset}} = socket
      ) do
    case TheArk.Repo.insert_or_update(off_days_changeset) do
      {:ok, _offday} ->
        socket
        |> put_flash(:info, "Off-days updated successfully!")
        |> assign(
          off_days_changeset: Offdays.change_offday(%Offday{}, %{year: Date.utc_today().year})
        )
        |> assign(chosen_month_for_offdays_modal: nil)
        |> assign(open_modal_id: nil)
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(off_days_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event("reset_offdays_modal", _payload, socket) do
    socket
    |> assign(
      off_days_changeset: Offdays.change_offday(%Offday{}, %{year: Date.utc_today().year})
    )
    |> assign(chosen_month_for_offdays_modal: nil)
    |> assign(open_modal_id: nil)
    |> assign(for_staff: false)
    |> assign(for_students: false)
    |> noreply()
  end

  @impl true
  def handle_event("open_offdays_modal", _payload, socket) do
    socket
    |> assign(
      off_days_changeset: Offdays.change_offday(%Offday{}, %{year: Date.utc_today().year})
    )
    |> assign(chosen_month_for_offdays_modal: nil)
    |> assign(open_modal_id: "off_days")
    |> assign(for_staff: false)
    |> assign(for_students: false)
    |> noreply()
  end

  @impl true
  def handle_event("open_end_month_modal", _payload, socket) do
    socket
    |> assign(open_modal_id: "end_of_month")
    |> noreply()
  end

  @impl true
  def handle_event(
        "offday_category",
        %{
          "_target" => ["offday_category", "for_staff"]
        },
        socket
      ) do
    socket
    |> assign(:for_staff, true)
    |> assign(for_students: false)
    |> assign(
      off_days_changeset:
        Offdays.change_offday(%Offday{}, %{
          year: Date.utc_today().year,
          for_students: false,
          for_staff: true
        })
    )
    |> assign(chosen_month_for_offdays_modal: nil)
    |> noreply()
  end

  @impl true
  def handle_event(
        "offday_category",
        %{
          "_target" => ["offday_category", "for_students"]
        },
        socket
      ) do
    socket
    |> assign(:for_students, true)
    |> assign(for_staff: false)
    |> assign(
      off_days_changeset:
        Offdays.change_offday(%Offday{}, %{
          year: Date.utc_today().year,
          for_students: true,
          for_staff: false
        })
    )
    |> assign(chosen_month_for_offdays_modal: nil)
    |> noreply()
  end

  @impl true
  def handle_event("end_of_year", _payload, socket) do
    socket
    |> assign(is_end_of_year: true)
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="font-bold text-3xl mb-5">Home</h1>

      <div class="flex gap-4 mb-5 items-center">
        <a href="/finances" class="ml-auto">Finances</a>
        <a href="/admissions">Admissions</a>
        <a href="/students">Students</a>
        <a href="/groups">Groups</a>
        <a href="/teachers">Teachers</a>
        <a href="/classes">Classes</a>
        <a href="/results">Results</a>
        <a href="/time_table">Time Table</a>
        <a href="/papers">Papers</a>
        <.form :let={f} class="relative" for={} as={:seach_student} phx-change="seach_student">
          <.input
            input_class="mt-0"
            field={f[:student_name]}
            type="text"
            placeholder="Search Student"
          />
          <div
            :if={@students_list}
            class="absolute end-0 right-0 bg-white py-2 border break-words rounded-lg w-80"
          >
            <%= for student <- @students_list do %>
              <div class="border-b py-1 px-3 hover:bg-blue-200 flex justify-between items-center">
                <a href={"/students/#{student.id}"} class="">
                  <%= student.name <> " " <> "(#{student.class.name})" %>
                </a>
                <a
                  href={"/groups/#{student.group_id}/finances"}
                  class="text-sm p-1 hover:text-black hover:bg-white rounded cursor-pointer text-white bg-black border border-black"
                >
                  Finance
                </a>
              </div>
            <% end %>
          </div>
        </.form>
      </div>

      <div class="grid grid-cols-7 gap-2">
        <.button phx-click={JS.push("open_offdays_modal") |> show_modal("off_days")}>
          Off days
        </.button>
        <.button
          :if={"first_term" not in @list_of_terms or @is_end_of_year}
          phx-click="terms_announcement"
          class="flex justify-center"
          phx-value-term_name="first_term"
        >
          Announce 1st Term
        </.button>
        <.button
          :if={"second_term" not in @list_of_terms}
          class="flex justify-center"
          phx-click="terms_announcement"
          phx-value-term_name="second_term"
        >
          Announce 2nd Term
        </.button>
        <.button
          :if={"third_term" not in @list_of_terms}
          phx-click="terms_announcement"
          class="flex justify-center"
          phx-value-term_name="third_term"
        >
          Announce 3rd Term
        </.button>
        <.button phx-click="end_of_year" class="flex justify-center">
          Mark End of Year
        </.button>
      </div>

      <div class="grid grid-cols-4 gap-2 mt-2">
        <.button phx-click={show_modal("class_registration_modal")} class="flex justify-center">
          Register New Class
        </.button>
        <.button class="flex justify-center" phx-click={show_modal("teacher_registration_modal")}>
          Register New Teacher
        </.button>
        <.button class="flex justify-center" phx-click={show_modal("student_registration_modal")}>
          Register New Student
        </.button>
        <.button class="flex justify-center" phx-click={show_modal("choose_fine_submission_class")}>
          Submit Absent Fines
        </.button>
        <.button class="flex justify-center" phx-click={show_modal("choose_test_configs")}>
          Initialize a Test
        </.button>
      </div>

      <div class="border rounded-lg grid grid-cols-3 gap-2 p-4 my-5">
        <div class="border rounded-lg p-2">
          Number of Students <%= @organization.number_of_students %> +
        </div>
        <div class="border rounded-lg p-2">
          Number of Staff members <%= @organization.number_of_staff %> +
        </div>
        <div class="border rounded-lg p-2">
          Years of Excellency <%= @organization.number_of_years %> +
        </div>
      </div>

      <div class="my-5 rounded-lg border flex p-2 items-center gap-10 justify-center">
        <div class="flex items-center gap-2">
          Edit Statistics
          <.button icon="hero-pencil" phx-click={show_modal("organization_editing")} />
        </div>
        <div class="flex items-center gap-2">
          Add Role <.button icon="hero-plus" phx-click={show_modal("role_adding")} />
        </div>
      </div>

      <.modal :if={@open_modal_id == "end_of_month"} show id="end_of_month">
        <% max_number = Date.utc_today().month + 1
        min_number = Date.utc_today().month - 3

        month_options =
          Enum.filter(@month_options, fn {_month, number} ->
            number > min_number and number < max_number
          end) %>
        <.form :let={f} for={} as={:end_of_month} phx-submit="end_of_month">
          <.input
            field={f[:month_number]}
            type="select"
            options={[{"none", 0}] ++ month_options}
            label="Choose Month for End"
          />

          <.button disabled={} class="mt-5">Submit</.button>
        </.form>
      </.modal>

      <%!-- :if={@open_modal_id == "off_days"} --%>
      <.modal
        :if={@open_modal_id == "off_days"}
        id="off_days"
        show
        on_cancel={JS.push("reset_offdays_modal") |> hide_modal("off_days")}
      >
        <.form :let={f} for={} as={:offday_category} phx-change="offday_category">
          <div class="font-bold text-sm">Updating the off-days for:</div>
          <div class="grid grid-cols-2 gap-2 mb-5">
            <.input field={f[:for_staff]} type="checkbox-custom" label="Staff" checked={@for_staff} />
            <.input
              field={f[:for_students]}
              type="checkbox-custom"
              label="Students"
              checked={@for_students}
            />
          </div>
        </.form>

        <.form
          :let={f}
          :if={@for_staff || @for_students}
          for={@off_days_changeset}
          phx-submit="submit_off_days"
          phx-change="validate_off_days"
        >
          <.input
            field={f[:month_number]}
            type="select"
            label="Choose Month"
            options={@month_options}
          />

          <div class="grid grid-cols-7 gap-2 mt-5">
            <%= for day <- ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"] do %>
              <div class="bg-sky-700 rounded-lg py-1 text-center text-white">
                <%= day %>
              </div>
            <% end %>
          </div>
          <div :if={@chosen_month_for_offdays_modal} class="grid grid-cols-7 gap-2 mt-5">
            <%= for {{day, date}, index} <- Enum.with_index(@month_dates) do %>
              <div class={
                classes(
                  "border border-sky-700 rounded-lg text-center",
                  %{
                    "col-start-1 col-end-2" =>
                      Enum.find_index(@days_of_week, &(&1 == day)) == 0 and index == 0,
                    "col-start-2 col-end-3" =>
                      Enum.find_index(@days_of_week, &(&1 == day)) == 1 and index == 0,
                    "col-start-3 col-end-4" =>
                      Enum.find_index(@days_of_week, &(&1 == day)) == 2 and index == 0,
                    "col-start-4 col-end-5" =>
                      Enum.find_index(@days_of_week, &(&1 == day)) == 3 and index == 0,
                    "col-start-5 col-end-6" =>
                      Enum.find_index(@days_of_week, &(&1 == day)) == 4 and index == 0,
                    "col-start-6 col-end-7" =>
                      Enum.find_index(@days_of_week, &(&1 == day)) == 5 and index == 0,
                    "col-start-7 col-end-8" =>
                      Enum.find_index(@days_of_week, &(&1 == day)) == 6 and index == 0
                  }
                )
              }>
                <% days = input_value(f, :days) %>
                <.field_type_option
                  type="custom_checkbox"
                  class=""
                  mini_class=""
                  name={date}
                  label={date}
                  checked={if days, do: date in days, else: nil}
                />
              </div>
            <% end %>
          </div>
          <div
            :if={!@chosen_month_for_offdays_modal}
            class="py-3 border rounded-lg text-gray-400 font-bold text-center mt-5"
          >
            Please choose month!
          </div>
          <.button disabled={!@off_days_changeset.valid?} class="mt-5">Submit</.button>
        </.form>
      </.modal>

      <.modal id="role_adding">
        <.form
          :let={f}
          for={@role_changeset}
          phx-submit="role_adding"
          phx-value-org_id={@organization.id}
        >
          <.input field={f[:name]} type="text" label="Name" />
          <.input field={f[:role]} type="text" label="Designation" />
          <.input field={f[:contact_number]} type="text" label="Contact Number" />

          <.button class="mt-5">Submit</.button>
        </.form>
      </.modal>

      <.modal id="organization_editing">
        <.form :let={f} for={@organization_changeset} phx-submit="update_organization">
          <.input field={f[:number_of_students]} type="number" label="Number of Students" />
          <.input field={f[:number_of_staff]} type="number" label="Number of Staff Members" />
          <.input field={f[:number_of_years]} type="number" label="Years of Excellency" />

          <.button class="mt-5">Submit</.button>
        </.form>
      </.modal>

      <div class="border rounded-lg p-5 flex flex-col gap-2">
        <%= for role <- @organization.roles do %>
          <div class="border rounded-lg p-2 flex items-center gap-2">
            <%= role.role %>
            <%= role.name %>
            <%= role.contact_number %>
            <.button
              icon="hero-pencil"
              phx-click={JS.push("role_editing_id") |> show_modal("role_#{role.id}_editing")}
              phx-value-role_id={role.id}
            />
          </div>

          <.modal id={"role_#{role.id}_editing"}>
            <%= if @role_editing_id == role.id do %>
              <.form :let={f} for={@role_changeset} phx-submit="edit_role" phx-value-role_id={role.id}>
                <.input field={f[:name]} type="text" label="Name" />
                <.input field={f[:role]} type="text" label="Designation" />
                <.input field={f[:contact_number]} type="text" label="Contact Number" />

                <.button class="mt-5">Submit</.button>
              </.form>
            <% end %>
          </.modal>
        <% end %>
      </div>

      <.modal id="choose_fine_submission_class">
        <.form :let={f} for={} as={:choose_class} phx-change="choose_fine_submission_class">
          <.input
            field={f[:class]}
            label="Choose Class"
            type="select"
            options={
              [{:none, 0}] ++ Enum.flat_map(@classes, fn class -> [{:"#{class.name}", class.id}] end)
            }
          />
        </.form>
      </.modal>

      <.modal id="choose_test_configs">
        <.form
          :let={f}
          for={@test_changeset}
          phx-submit="submit_test_init"
          phx-change="validate_test_init"
        >
          <.input
            field={f[:class_id]}
            label="Choose Class"
            type="select"
            options={
              [{:none, 0}] ++ Enum.flat_map(@classes, fn class -> [{:"#{class.name}", class.id}] end)
            }
          />
          <.input
            field={f[:subject]}
            label="Choose Subject"
            type="select"
            options={@test_subject_options}
          />
          <.input field={f[:total_marks]} label="Total Marks" type="number" />
          <.input field={f[:date_of_test]} label="Date of Test" type="date" />

          <.button class="mt-5">Initialize Test</.button>
        </.form>
      </.modal>

      <.modal id="class_registration_modal">
        <div class="p-2 border rounded-lg">
          <h2 class="font-bold text-lg mb-2">Class Registration</h2>
          <.form
            :let={f}
            for={@class_changeset}
            phx-change="class_validation"
            phx-submit="class_submission"
          >
            <.input field={f[:name]} type="text" label="Class Name" />
            <.input
              field={f[:incharge]}
              type="select"
              label="Incharge Name"
              options={List.insert_at(Enum.map(@teachers, fn teacher -> teacher.name end), 0, "")}
            />
            <MultiSelect.multi_select
              id="subjects"
              on_change={fn opts -> send(self(), {:updated_options, opts}) end}
              form={f}
              options={@subject_options}
              wrap={false}
              max_selected={7}
              placeholder="Select subjects..."
              title="Select Subjects"
            />
            <.button class="mt-4">Submit</.button>
          </.form>
        </div>
      </.modal>
      <.modal id="student_registration_modal">
        <div class="p-2 border rounded-lg">
          <h2 class="font-bold text-lg mb-2">Student Registration</h2>
          <.form
            :let={s}
            for={@student_changeset}
            phx-change="student_validation"
            phx-submit="student_submission"
          >
            <.input field={s[:name]} type="text" label="Student Name" />
            <.input field={s[:father_name]} type="text" label="Father Name" />
            <.input field={s[:address]} type="text" label="Address" />
            <.input
              field={s[:class_id]}
              type="select"
              label="Class of Enrollment"
              options={Enum.flat_map(@classes, fn class -> [{:"#{class.name}", class.id}] end)}
            />
            <.input field={s[:date_of_birth]} type="date" label="Date of Birth" />
            <.input field={s[:cnic]} type="text" label="Student CNIC" />
            <.input field={s[:guardian_cnic]} type="text" label="Guardian CNIC" />
            <.input field={s[:sim_number]} type="text" label="Contact Number (without whatsapp)" />
            <.input field={s[:whatsapp_number]} type="text" label="Whatsapp Number" />

            <.button class="mt-5">Submit</.button>
          </.form>
        </div>
      </.modal>

      <.modal id="teacher_registration_modal">
        <div class="p-2 border rounded-lg">
          <h2 class="font-bold text-lg mb-2">Teacher Registration</h2>
          <.form
            :let={s}
            for={@teacher_changeset}
            phx-change="teacher_validation"
            phx-submit="teacher_submission"
          >
            <.input field={s[:name]} type="text" label="Teacher Name" />
            <.input field={s[:father_name]} type="text" label="Father Name" />
            <.input
              field={s[:education]}
              type="select"
              label="Education"
              options={["Inter", "Bachelors", "Masters"]}
            />
            <.input field={s[:address]} type="text" label="Address" />
            <.input field={s[:cnic]} type="text" label="CNIC" />
            <.input field={s[:sim_number]} type="text" label="Contact Number (without whatsapp)" />
            <.input field={s[:whatsapp_number]} type="text" label="Whatsapp Number" />

            <.button class="mt-5">Submit</.button>
          </.form>
        </div>
      </.modal>
    </div>
    """
  end

  def generate_registration_number(number) do
    number
    |> String.split("-")
    |> then(fn list ->
      list
      |> List.update_at(-1, fn x -> ((x |> String.to_integer()) + 1) |> Integer.to_string() end)
      |> List.update_at(-2, fn _x ->
        Date.utc_today().year |> Integer.to_string() |> String.slice(2, 2)
      end)
    end)
    |> Enum.join("-")
  end

  def month_dates(%{assigns: %{chosen_month_for_offdays_modal: month_number}} = socket) do
    {:ok, first_date} = Date.new(Date.utc_today().year, month_number, 1)
    total_days = Timex.days_in_month(first_date)

    dates =
      Enum.map(1..total_days, fn day_num ->
        date = Date.add(first_date, day_num - 1)
        day_of_week = Date.day_of_week(date)
        day_name = Enum.at(@days_of_week, day_of_week - 1)

        {day_name, date.day}
      end)

    socket
    |> assign(month_dates: dates)
  end
end
