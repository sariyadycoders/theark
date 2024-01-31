defmodule TheArkWeb.RegistrationLive do
  use TheArkWeb, :live_view

  alias TheArk.{Classes,
                Classes.Class,
                Students,
                Students.Student,
                Teachers,
                Teachers.Teacher,
                Subjects,
                # Subjects,Subject
              }

  # import Ecto.Changeset
  alias Phoenix.LiveView.Components.MultiSelect

  @impl true
  def mount(_params, _session, socket) do

    socket
    |> assign(classes: Classes.list_classes)
    |> assign(class_changeset: Classes.change_class(%Class{}))
    |> assign(student_changeset: Students.change_student(%Student{}))
    |> assign(teacher_changeset: Teachers.change_teacher(%Teacher{}))
    |> assign(subject_options: Subjects.list_subject_options)
    |> ok
  end

  @impl true
  def handle_info({:updated_options, opts}, socket) do
    socket
    |> assign(subject_options: opts)
    |> noreply
  end

  @impl true
  def handle_event("class_validation", %{"class" => params} , socket) do
    class_changeset = Classes.change_class(%Class{}, params) |> Map.put(:action, :insert)

    socket
    |> assign(class_changeset: class_changeset)
    |> noreply()
  end

  @impl true
  def handle_event("class_submission",
                  %{"class" => class_params},
                  %{assigns: %{subject_options: subject_options}} = socket) do
    case Classes.create_class(class_params, subject_options) do
      {:ok, _class} ->

        socket
        |> assign(class_changeset: Classes.change_class(%Class{}))
        |> assign(subject_options: Enum.map(subject_options, fn subject -> Map.delete(subject, :selected) end))
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
  def render(assigns) do
    ~H"""
      <h1 class="font-bold text-3xl mb-5">Registrations</h1>
      <div class="grid grid-cols-2 gap-2">
        <div class="p-2 border rounded-lg">
          <h2 class="font-bold text-lg mb-2">Class Registration</h2>
          <.form :let={f} for={@class_changeset} phx-change="class_validation" phx-submit="class_submission">
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
            <.button class={"mt-5 #{!@class_changeset.valid? && "hidden"}"}>Submit</.button>
          </.form>
        </div>
        <div class="p-2 border rounded-lg">
          <h2 class="font-bold text-lg mb-2">Student Registration</h2>
          <.form :let={s} for={@student_changeset} phx-change="student_validation" phx-submit="student_submission">
            <.input field={s[:name]} type="text" label="Student Name" />
            <.input field={s[:father_name]} type="text" label="Father Name" />
            <.input field={s[:age]} type="number" label="Age" />
            <.input field={s[:class_id]} type="select" label="Class" options={Enum.flat_map(@classes, fn class -> ["#{class.name}": class.id] end)} />

            <.button class="mt-5">Submit</.button>
          </.form>
        </div>
        <div class="p-2 border rounded-lg">
          <h2 class="font-bold text-lg mb-2">Teacher Registration</h2>
          <.form :let={s} for={@teacher_changeset} phx-change="teacher_validation" phx-submit="teacher_submission">
            <.input field={s[:name]} type="text" label="Teacher Name" />
            <.input field={s[:date_of_joining]} type="date" label="Date of Joining" />


            <.button class="mt-5">Submit</.button>
          </.form>
        </div>
      </div>

    """
  end

end
