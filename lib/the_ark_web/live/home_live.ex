defmodule TheArkWeb.Home do
  use TheArkWeb, :live_view

  alias TheArk.{
    Classes,
    Classes.Class,
    Students,
    Students.Student,
    Teachers,
    Teachers.Teacher,
    Subjects
    # Subjects,Subject
  }

  # import Ecto.Changeset
  alias Phoenix.LiveView.Components.MultiSelect

  @impl true
  def mount(_, _, socket) do
    socket
    |> assign(classes: Classes.list_classes())
    |> assign(class_changeset: Classes.change_class(%Class{}))
    |> assign(student_changeset: Students.change_student(%Student{}))
    |> assign(teacher_changeset: Teachers.change_teacher(%Teacher{}))
    |> assign(subject_options: Subjects.list_subject_options())
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
        |> assign(
          subject_options:
            Enum.map(subject_options, fn subject -> Map.delete(subject, :selected) end)
        )
        |> put_flash(:success, message: "Class is successfully created!")
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
    case Teachers.create_teacher(params) do
      {:ok, _class} ->
        socket
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
      {:ok, _class} ->
        socket
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
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="font-bold text-3xl mb-5">Home</h1>
      <div class="grid grid-cols-6 gap-2">
        <.button phx-click="terms_announcement"
          class="flex justify-center"
          phx-value-term_name="first_term"
          phx-value-type="true">
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
        <.button phx-click="terms_announcement"
          class="flex justify-center"
          phx-value-term_name="third_term"
          phx-value-type="true">
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

      <div class="grid grid-cols-3 gap-2 mt-2">
        <.button phx-click={show_modal("class_registration_modal")}
          class="flex justify-center">
          Register New Class
        </.button>
        <.button
          class="flex justify-center"
          phx-click={show_modal("teacher_registration_modal")}
        >
          Register New Teacher
        </.button>
        <.button
          class="flex justify-center"
          phx-click={show_modal("student_registration_modal")}
        >
          Register New Student
        </.button>
      </div>

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
            <.input field={f[:incharge]} type="text" label="Incharge Name" />
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
            <.input field={s[:date_of_joining]} type="date" label="Date of Joining" />

            <.button class="mt-5">Submit</.button>
          </.form>
        </div>
      </.modal>
    </div>
    """
  end
end
