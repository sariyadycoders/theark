defmodule TheArkWeb.TeacherLive do
  use TheArkWeb, :live_view

  alias TheArk.{
    Teachers,
    Subjects,
    Classes
  }

  alias Phoenix.LiveView.Components.MultiSelect

  @impl true
  def mount(_, _, socket) do
    socket
    |> assign(teachers: Teachers.list_teachers())
    |> assign(classes: Classes.list_classes())
    |> assign(edit_teacher_id: 0)
    |> assign(assign_subjects_to_teacher_id: 0)
    |> assign(delete_teacher_id: 0)
    |> assign(is_class_choosen: false)
    |> ok
  end

  @impl true
  def handle_info({:updated_options, opts}, socket) do
    socket
    |> assign(subject_options: opts)
    |> noreply
  end

  @impl true
  def handle_event("edit_teacher_id", %{"teacher_id" => "0"}, socket) do
    socket
    |> assign(edit_teacher_id: 0)
    |> assign(delete_teacher_id: 0)
    |> noreply()
  end

  @impl true
  def handle_event("edit_teacher_id", %{"teacher_id" => id}, socket) do
    teacher = Teachers.get_teacher!(String.to_integer(id))
    teacher_changeset = Teachers.change_teacher(teacher)

    socket
    |> assign(teacher_changeset: teacher_changeset)
    |> assign(edit_teacher_id: String.to_integer(id))
    |> assign(delete_teacher_id: 0)
    |> noreply()
  end

  @impl true
  def handle_event("delete_teacher_id", %{"teacher_id" => id}, socket) do
    socket
    |> assign(delete_teacher_id: String.to_integer(id))
    |> assign(edit_teacher_id: 0)
    |> noreply
  end

  @impl true
  def handle_event("assign_subjects_to_teacher_id", %{"teacher_id" => id}, socket) do
    socket
    |> assign(assign_subjects_to_teacher_id: String.to_integer(id))
    |> assign(edit_teacher_id: 0)
    |> assign(delete_teacher_id: 0)
    |> noreply()
  end

  def handle_event(
        "assign_subjects_to_teacher",
        %{"teacher_id" => teacher_id},
        %{assigns: %{subject_options: subject_options, choosen_class_id: choosen_class_id}} =
          socket
      ) do
    Subjects.assign_subjects_to_teacher(subject_options, choosen_class_id, teacher_id)

    socket
    |> assign(teachers: Teachers.list_teachers())
    |> assign(is_class_choosen: false)
    |> noreply()
  end

  @impl true
  def handle_event("class_of_subject", %{"class_of_subject" => %{"class" => class_id}, "teacher_id" => teacher_id}, socket) do
    IO.inspect "challll"

    teacher = Teachers.get_teacher!(teacher_id)

    teacher_already_subjects_ids =
      Enum.map(teacher.subjects, fn subject -> subject.subject_id end)

    subject_options =
      Subjects.get_subjects_of_class(String.to_integer(class_id))
      |> Enum.map(fn subject ->
        if subject.id in teacher_already_subjects_ids do
          Map.put(subject, :selected, true)
        else
          Map.put(subject, :selected, false)
        end
      end)

    socket
    |> assign(is_class_choosen: true)
    |> assign(choosen_class_id: String.to_integer(class_id))
    |> assign(subject_options: subject_options)
    |> noreply()
  end

  @impl true
  def handle_event(
        "subject_teacher_change",
        %{"prev_teacher_id" => prev_id, "subject_teacher_change" => %{"teacher_id" => new_id}},
        socket
      ) do
    Subjects.replace_teacher_id_of_subjects(prev_id, new_id)
    Teachers.delete_teacher_by_id(String.to_integer(prev_id))

    socket
    |> assign(teachers: Teachers.list_teachers())
    |> assign(edit_teacher_id: 0)
    |> assign(delete_teacher_id: 0)
    |> noreply
  end

  @impl true
  def handle_event("teacher_updation", %{"teacher" => params, "teacher_id" => id}, socket) do
    teacher = Teachers.get_teacher!(String.to_integer(id))

    case Teachers.update_teacher(teacher, params) do
      {:ok, _class} ->
        socket
        |> assign(edit_teacher_id: 0)
        |> assign(teachers: Teachers.list_teachers())
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(teacher_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event("teacher_validation", %{"teacher" => params, "teacher_id" => id}, socket) do
    teacher = Teachers.get_teacher!(String.to_integer(id))
    teacher_changeset = Teachers.change_teacher(teacher, params) |> Map.put(:action, :insert)

    socket
    |> assign(teacher_changeset: teacher_changeset)
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="font-bold text-3xl mb-5">Teachers</h1>
      <div class="grid grid-cols-6 items-center border-b-4 pb-2 font-bold text-lg mb-2">
        <div>
          Name
        </div>
        <div>
          Education
        </div>
        <div>
          Service
        </div>
        <div>
          Contact
        </div>
        <div class="">
          Is Active?
        </div>
        <div class="">
          actions
        </div>
      </div>
      <%= for teacher <- @teachers do %>
        <div class="grid grid-cols-6 items-center pb-2">
          <div>
            <%= teacher.name %>
          </div>
          <div>
            <%= teacher.education %>
          </div>
          <div>
            <%= get_service(teacher.registration_date) %>
          </div>
          <div>
            <div><b>W: </b><%= teacher.whatsapp_number %></div>
            <div><b>S: </b><%= teacher.sim_number %></div>
          </div>
          <div>
            <%= if teacher.is_leaving, do: "No", else: "Yes" %>
          </div>
          <div>
            <.button
              class={""}
              phx-click="edit_teacher_id"
              phx-value-teacher_id={teacher.id}
            >
              Edit
            </.button>
            <.button
              class={""}
              phx-click="delete_teacher_id"
              phx-value-teacher_id={teacher.id}
            >
              Delete
            </.button>
            <.button
              class={""}
              phx-click={show_modal("assign_subjects_to_teacher_#{teacher.id}")}
              phx-value-teacher_id={teacher.id}
            >
              Assign Subjects
            </.button>
          </div>
          <div class="col-span-2">
            <%= for subject <- teacher.subjects do %>
              <%= "#{subject.class.name}: #{subject.name} |" %>
            <% end %>
          </div>
        </div>

        <.modal id={"assign_subjects_to_teacher_#{teacher.id}"}>
          <div class="p-2 mt-2">
            <h2 class="font-bold mb-2">
              Choose class and assign subjects to Miss <%= teacher.name %>
            </h2>
            <div class="flex gap-2">
              <.form :let={s} for={%{}} as={:class_of_subject} phx-change="class_of_subject" phx-value-teacher_id={teacher.id}>
                <.input
                  field={s[:class]}
                  type="select"
                  label="Class"
                  options={Enum.flat_map(@classes, fn class -> [{:"#{class.name}", class.id}] end)}
                />
              </.form>
              <div :if={!@is_class_choosen} class="flex items-end">
                <div class="border rounded-lg p-2 flex items-end">
                  Please choose class to show its subjects.
                </div>
              </div>
            </div>
            <div :if={@is_class_choosen}>
              <.form
                :let={f}
                for={%{}}
                as={:class_of_subject}
                phx-value-teacher_id={teacher.id}
                phx-submit="assign_subjects_to_teacher"
              >
                <MultiSelect.multi_select
                  id={"subjects_#{teacher.id}"}
                  on_change={fn opts -> send(self(), {:updated_options, opts}) end}
                  form={f}
                  options={@subject_options}
                  max_selected={7}
                  placeholder="Select subjects..."
                  title="Select Subjects"
                />

                <.button class="mt-5">Submit</.button>
              </.form>
            </div>
          </div>
        </.modal>

        <%= if @delete_teacher_id == teacher.id do %>
          <div class="relative border p-3 rounded-lg w-1/2">
            <div
              phx-click="delete_teacher_id"
              phx-value-teacher_id="0"
              class="absolute top-2 right-2 cursor-pointer"
            >
              &#9746;
            </div>
            <div class="p-2 mt-2">
              <h2 class="font-bold mb-2">
                Subjects of Miss <%= teacher.name %> should be transfered to:
              </h2>
              <.form
                :let={s}
                for={%{}}
                as={:subject_teacher_change}
                phx-value-prev_teacher_id={teacher.id}
                phx-submit="subject_teacher_change"
              >
                <.input
                  field={s[:teacher_id]}
                  type="select"
                  label="Teacher"
                  options={
                    Enum.flat_map(@teachers, fn teacher -> [{:"#{teacher.name}", teacher.id}] end)
                  }
                />

                <.button class="mt-5">Transfer Subjects and Delete Teacher</.button>
              </.form>
            </div>
          </div>
        <% end %>
        <%= if @edit_teacher_id == teacher.id do %>
          <div class="relative border p-3 w-1/2 rounded-lg">
            <div
              phx-click="edit_teacher_id"
              phx-value-teacher_id="0"
              class="absolute top-2 right-2 cursor-pointer"
            >
              &#9746;
            </div>
            <.form
              :let={f}
              for={@teacher_changeset}
              phx-change="teacher_validation"
              phx-submit="teacher_updation"
              phx-value-teacher_id={teacher.id}
            >
              <.input field={f[:name]} type="text" label="Class Name" />
              <.input field={f[:date_of_joining]} type="date" label="Incharge Name" />

              <.button class="mt-5">Submit</.button>
            </.form>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  def get_service(registration_date) do
    days_till_joining = Date.diff(Date.utc_today(), registration_date)

    if days_till_joining > 365 do
      number_of_years = (days_till_joining/365) |> floor()
      extra_days = rem(days_till_joining, 365)
      number_of_months = (extra_days/30) |> floor()

      "#{number_of_years} Years #{if number_of_months > 0, do: "and #{number_of_months} Months"}"
    else
      number_of_months = (days_till_joining/30) |> floor()

      "#{number_of_months} Months"
    end
  end
end
