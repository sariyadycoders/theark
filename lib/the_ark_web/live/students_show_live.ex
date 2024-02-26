defmodule TheArkWeb.StudentsShowLive do
  use TheArkWeb, :live_view

  import TheArkWeb.ClassResultLive, only: [get_total_marks_of_term_from_results: 2, get_obtained_marks_of_term_from_results: 2, get_percentage_of_marks: 2]

  alias TheArk.Students
  alias TheArk.Classes
  alias TheArk.Students.Student

  @impl true
  def mount(%{"id" => student_id}, _, socket) do
    socket
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

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div>
        <h1 class="font-bold text-3xl"><%= @student.name %></h1>
        <div class="ml-5">S/O <%= @student.father_name %></div>
      </div>

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
              <%= if get_percentage_of_marks(subject.results, @term_name) > 32, do: "Pass", else: "Fail" %>
            </div>
          </div>
        <% end %>
      </div>

      <div class="grid grid-cols-2 p-5 border rounded-lg mt-5 gap-2">
        <div class="border p-2">
          <b class="capitalize"> Class:</b>
          <%= @student.class.name %>
        </div>
        <%= for student_key <- get_student_keys(@student) do %>
          <%= if student_key not in [:is_leaving, :last_attendance_date, :leaving_certificate_date, :leaving_class] do %>
            <div class="border p-2">
              <b class="capitalize">
                <%= Atom.to_string(student_key) |> String.replace("_", " ") %>:
              </b>
              <%= if Map.get(@student, student_key), do: Map.get(@student, student_key), else: "nil" %>
            </div>
          <% else %>
            <%= if @student.is_leaving do %>
              <div class="border p-2">
                <b class="capitalize">
                  <%= Atom.to_string(student_key) |> String.replace("_", " ") %>:
                </b>
                <%= if Map.get(@student, student_key), do: Map.get(@student, student_key), else: "nil" %>
              </div>
            <% end %>
          <% end %>
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

  def get_student_keys(student) do
    Map.keys(Map.from_struct(student))
    |> Enum.reject(fn x ->
      x in [
        :updated_at,
        :inserted_at,
        :subjects,
        :class,
        :class_id,
        :__meta__,
        :id,
        :name,
        :father_name
      ]
    end)
  end
end
