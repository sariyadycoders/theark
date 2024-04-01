defmodule TheArkWeb.StudentsShowLive do
  use TheArkWeb, :live_view

  import TheArkWeb.ClassResultLive,
    only: [
      get_total_marks_of_term_from_results: 2,
      get_obtained_marks_of_term_from_results: 2,
      get_percentage_of_marks: 2
    ]

  alias TheArk.{
    Students,
    Classes,
    Students.Student,
    Groups,
    Notes,
    Notes.Note
  }

  @options [
    "Books",
    "Copies",
    "Monthly Fee",
    "1st Term Paper Fund",
    "2nd Term Paper Fund",
    "3rd Term Paper Fund",
    "Anual Charges",
    "Tour Fund",
    "Party Fund",
    "Registration Fee",
    "Admission Fee",
    "Remainings"
  ]

  @impl true
  def mount(%{"id" => student_id}, _, socket) do
    groups = Groups.list_groups_for_assign()

    group_options =
      Enum.flat_map(groups, fn group ->
        ["#{group.name}": group.id]
      end)

    socket
    |> assign(options: @options)
    |> assign(note_changeset: Notes.change_note(%Note{}))
    |> assign(group_options: group_options)
    |> assign(student: Students.get_student!(String.to_integer(student_id)))
    |> assign(class_options: Classes.get_class_options())
    |> assign(is_leaving_form_open: false)
    |> assign(surety_of_reactivation: false)
    |> assign(student_leaving_changeset: Students.change_student_leaving(%Student{}))
    |> assign(is_leaving_button: true)
    |> assign(term_name: nil)
    |> ok
  end

  @impl true
  def handle_event("student_leaving_form", %{"is_leaving" => is_leaving}, socket) do
    is_leaving = if is_leaving == "true", do: true, else: false

    if is_leaving do
      socket
      |> assign(surety_of_reactivation: true)
      |> assign(is_leaving_button: false)
      |> noreply()
    else
      socket
      |> assign(is_leaving_form_open: true)
      |> assign(is_leaving_button: false)
      |> noreply()
    end
  end

  @impl true
  def handle_event(
        "leaving_form_submission",
        %{"student_id" => id, "student" => student_params},
        socket
      ) do
    student = Students.get_student_only(String.to_integer(id))

    case Students.update_student_leaving(student, student_params) do
      {:ok, student} ->
        socket
        |> assign(student_leaving_changeset: Students.change_student_leaving(%Student{}))
        |> put_flash(:info, "#{student.name} has leaved the school!")
        |> assign(is_leaving_form_open: false)
        |> assign(is_leaving_button: true)
        |> assign(student: Students.get_student!(String.to_integer(id)))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(student_leaving_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event("reactivate_student", %{"student_id" => id}, socket) do
    Students.reactivate_student(String.to_integer(id))

    socket
    |> put_flash(:info, "Student is re-activated successfully!")
    |> assign(is_leaving_button: true)
    |> assign(surety_of_reactivation: false)
    |> assign(student: Students.get_student!(String.to_integer(id)))
    |> noreply()
  end

  @impl true
  def handle_event(
        "student_transfer_submit",
        %{"student_id" => student_id, "student_class" => %{"class_id" => class_id}},
        socket
      ) do
    student = Students.get_student!(student_id)
    {:ok, _student} = Students.update_student(student, %{"class_id" => class_id})

    socket
    |> assign(student: Students.get_student!(student_id))
    |> put_flash(:info, "Student updated successfully!")
    |> noreply()
  end

  @impl true
  def handle_event("choose_term", %{"term_name" => term_name}, socket) do
    socket
    |> assign(term_name: term_name)
    |> noreply()
  end

  def handle_event("assign_group", %{"assign_group" => %{"group_id" => id}}, %{assigns: %{student: student}} = socket) do
    group = Groups.get_group!(id)
    {:ok, _student} = Students.update_student(student, %{group_id: String.to_integer(id)})

    socket
    |> put_flash(:info, "Student successfully registered in #{group.name}")
    |> noreply()
  end

  def handle_event("add_note", %{"note" => params, "student_id" => id}, socket) do
    case Notes.create_note(Map.put(params, "student_id", id)) do
      {:ok, _} ->
        socket
        |> put_flash(:info, "Note added successfully!")
        |> assign(note_changeset: Notes.change_note(%Note{}))
        |> noreply()
      {:error, changeset} ->
        socket
        |> assign(note_changeset: changeset)
        |> noreply()
    end
  end

  def handle_event("validate_note", %{"note" => params, "student_id" => id}, socket) do
    socket
    |> assign(note_changeset: Notes.change_note(%Note{}, Map.put(params, "student_id", id)))
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between">
        <div class="">
          <h1 class="font-bold text-3xl"><%= @student.name %></h1>
          <div class="ml-5">S/O <%= @student.father_name %></div>
        </div>
        <div class="flex gap-2">
          <.form :let={f} for={} as={:assign_group} phx-submit="assign_group" class="flex items-end gap-2">
            <.input
              field={f[:group_id]}
              type="select"
              label={"Assign Group to #{@student.name}"}
              options={@group_options}
            />

            <.button>Confirm Group</.button>
          </.form>
          <div class="flex items-end"><.button phx-click={show_modal("add_note")}>Add Note</.button></div>
        </div>
      </div>
      <.modal id="add_note">
        <.form :let={f} for={@note_changeset} phx-submit="add_note" phx-change="validate_note" phx-value-student_id={@student.id}>
          <.input field={f[:title]} type="text" label="Title"/>
          <.input field={f[:description]} type="textarea" label="Important Note"/>

          <.button class="mt-5">Add</.button>
        </.form>
      </.modal>

      <div class="flex items-center gap-2 my-5">
        <%= for term_name <- Classes.make_list_of_terms() do %>
          <.button phx-click="choose_term" phx-value-term_name={term_name}>
            See <%= term_name |> String.replace("_", " ") %> Result Card
          </.button>
        <% end %>
      </div>

      <div :if={@term_name} class="w-full p-5 border rounded-lg my-5">
        <div class="grid grid-cols-5 items-center font-bold">
          <div class="border flex flex-col py-2">
            <div class="col-span-2 text-center">Subject Name</div>
          </div>
          <div class="border flex flex-col py-2">
            <div class="col-span-2 text-center">Total Marks</div>
          </div>
          <div class="border flex flex-col py-2">
            <div class="col-span-2 text-center">Obtained Marks</div>
          </div>
          <div class="border flex flex-col py-2">
            <div class="col-span-2 text-center">Percentage</div>
          </div>
          <div class="border flex flex-col py-2">
            <div class="col-span-2 text-center">Status</div>
          </div>
        </div>
        <%= for subject <- @student.subjects do %>
          <div class="grid grid-cols-5 items-center">
            <div class="border pl-2 py-1">
              <%= subject.name %>
            </div>
            <div class="border pl-2 py-1 text-center">
              <%= get_total_marks_of_term_from_results(subject.results, @term_name) %>
            </div>
            <div class="border pl-2 py-1 text-center">
              <%= get_obtained_marks_of_term_from_results(subject.results, @term_name) %>
            </div>
            <div class="border pl-2 py-1 text-center">
              <%= get_percentage_of_marks(subject.results, @term_name) %>
            </div>
            <div class="border pl-2 py-1 text-center">
              <%= if get_percentage_of_marks(subject.results, @term_name) > 32,
                do: "Pass",
                else: "Fail" %>
            </div>
          </div>
        <% end %>
      </div>

      <div class="grid grid-cols-2 p-5 border rounded-lg mt-5 gap-2">
        <div class="border p-2">
          <b class="capitalize"> Class:</b>
          <%= @student.class.name %>
        </div>
        <div class="border p-2">
          <b class="capitalize">
            Father Name:
          </b>
          <%= @student.father_name %>
        </div>

        <div class="border p-2">
          <b class="capitalize">
            Address:
          </b>
          <%= @student.address %>
        </div>
        <div class="border p-2">
          <b class="capitalize">
            Date of Birth:
          </b>
          <%= @student.date_of_birth %>
        </div>
        <div class="border p-2">
          <b class="capitalize">
            CNIC:
          </b>
          <%= @student.cnic %>
        </div>
        <div class="border p-2">
          <b class="capitalize">
            Guardian CNIC:
          </b>
          <%= @student.guardian_cnic %>
        </div>
        <div class="border p-2">
          <b class="capitalize">
            Sim Number:
          </b>
          <%= @student.sim_number %>
        </div>
        <div class="border p-2">
          <b class="capitalize">
            Whatsapp:
          </b>
          <%= @student.whatsapp_number %>
        </div>
        <div class="border p-2">
          <b class="capitalize">
            Class of Enrollment:
          </b>
          <%= @student.class_of_enrollment %>
        </div>
        <div class="border p-2">
          <b class="capitalize">
            Enrollment Number:
          </b>
          <%= @student.enrollment_number %>
        </div>
        <div class="border p-2">
          <b class="capitalize">
            Enrollment Date:
          </b>
          <%= @student.enrollment_date %>
        </div>
        <%= if @student.is_leaving do %>
          <div class="border p-2">
            <b class="capitalize">
              Leaving Class:
            </b>
            <%= @student.leaving_class %>
          </div>
          <div class="border p-2">
            <b class="capitalize">
              Leaving Cer. Date:
            </b>
            <%= @student.leaving_certificate_date %>
          </div>
          <div class="border p-2">
            <b class="capitalize">
              Last Attendace:
            </b>
            <%= @student.last_attendance_date %>
          </div>
        <% end %>
      </div>
      <div class="flex gap-3">
        <.button phx-click={show_modal("student_transfer")} class="mt-5">
          Transfer Student
        </.button>
        <.button
          :if={@is_leaving_button}
          phx-click="student_leaving_form"
          phx-value-is_leaving={if !@student.is_leaving, do: "false", else: "true"}
          class="mt-5"
        >
          <%= if !@student.is_leaving, do: "Is Leaving", else: "Re-activate" %>
        </.button>
      </div>
      <%= if @is_leaving_form_open do %>
        <div class="border p-5 rounded-lg mt-5">
          <.form
            :let={s}
            for={@student_leaving_changeset}
            phx-submit="leaving_form_submission"
            phx-value-student_id={@student.id}
          >
            <.input field={s[:is_leaving]} type="hidden" value="true" />
            <.input field={s[:leaving_class]} type="hidden" value={@student.class.name} />
            <.input field={s[:leaving_certificate_date]} type="date" label="Leaving Certificate Date" />
            <.input field={s[:last_attendance_date]} type="date" label="Last Attendance Date" />

            <.button class="mt-5">Submit</.button>
          </.form>
        </div>
      <% end %>
      <%= if @surety_of_reactivation do %>
        <div class="border p-5 rounded-lg mt-5 flex justify-between items-center">
          <div>
            Are you sure to re-activate <%= @student.name %>?
          </div>
          <.button phx-click="reactivate_student" phx-value-student_id={@student.id}>Yes</.button>
        </div>
      <% end %>
      <.modal id="student_transfer">
        <.form
          :let={s}
          for={}
          as={:student_class}
          phx-submit="student_transfer_submit"
          phx-value-student_id={@student.id}
        >
          <.input
            field={s[:class_id]}
            type="select"
            label="Class of Enrollment"
            options={@class_options}
          />

          <.button class="mt-5">Submit</.button>
        </.form>
      </.modal>
    </div>
    """
  end
end
