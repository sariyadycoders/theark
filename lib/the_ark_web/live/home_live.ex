defmodule TheArkWeb.Home do
  alias TheArk.Organizations
  use TheArkWeb, :live_view

  # TODO: Result preparation start

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
    Attendances
  }

  # import Ecto.Changeset
  alias Phoenix.LiveView.Components.MultiSelect

  @impl true
  def mount(_, _, socket) do
    organization = Organizations.get_organization_by_name("the_ark")

    socket
    |> assign(classes: Classes.list_classes())
    |> assign(teachers: Teachers.list_teachers())
    |> assign(class_changeset: Classes.change_class(%Class{}))
    |> assign(student_changeset: Students.change_student(%Student{}))
    |> assign(teacher_changeset: Teachers.change_teacher(%Teacher{}))
    |> assign(role_changeset: Roles.change_role(%Role{}))
    |> assign(role_editing_id: 0)
    |> assign(organization_changeset: Organizations.change_organization(organization))
    |> assign(subject_options: Subjects.list_subject_options())
    |> assign(organization: organization)
    |> assign(students_list: nil)
    |> assign(current_month_number: Date.utc_today().month)
    |> ok
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
  def handle_event("terms_announcement", %{"term_name" => term_name, "type" => type}, socket) do
    type = if type == "true", do: true, else: false
    Classes.term_announcement(term_name, type)

    socket
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
        _,
        %{assigns: %{current_month_number: current_month_number}} = socket
      ) do
    Attendances.create_monthly_attendances(current_month_number)

    socket
    |> noreply()
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
        <.button phx-click="end_of_month">Mark End of Month</.button>

        <.button
          phx-click="terms_announcement"
          class="flex justify-center"
          phx-value-term_name="first_term"
          phx-value-type="true"
        >
          Announce 1st Term
        </.button>
        <.button
          class="flex justify-center"
          phx-click="terms_announcement"
          phx-value-term_name="first_term"
          phx-value-type="false"
        >
          Finish 1st Term
        </.button>
        <.button
          class="flex justify-center"
          phx-click="terms_announcement"
          phx-value-term_name="second_term"
          phx-value-type="true"
        >
          Announce 2nd Term
        </.button>
        <.button
          class="flex justify-center"
          phx-click="terms_announcement"
          phx-value-term_name="second_term"
          phx-value-type="false"
        >
          Finish 2nd Term
        </.button>
        <.button
          phx-click="terms_announcement"
          class="flex justify-center"
          phx-value-term_name="third_term"
          phx-value-type="true"
        >
          Announce 3rd Term
        </.button>
        <.button
          phx-click="terms_announcement"
          phx-value-term_name="third_term"
          phx-value-type="false"
          class="flex justify-center"
        >
          Finish 3rd Term
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
            options={[{:none, 0}] ++ Enum.flat_map(@classes, fn class -> [{:"#{class.name}", class.id}] end)}
          />
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
end
