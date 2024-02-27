defmodule TheArkWeb.TeacherShowLive do
  use TheArkWeb, :live_view

  alias TheArk.Teachers

  @impl true
  def mount(%{"id" => id}, _, socket) do
    teacher = Teachers.get_teacher!(id)
    teacher_changeset = Teachers.change_teacher(teacher)

    socket
    |> assign(teacher: teacher)
    |> assign(teacher_changeset: teacher_changeset)
    |> ok
  end

  @impl true
  def handle_event("teacher_updation", %{"teacher" => params}, %{assigns: %{teacher: teacher}} = socket) do

    case Teachers.update_teacher(teacher, params) do
      {:ok, teacher} ->
        socket
        |> assign(teacher: teacher)
        |> assign(teacher_changeset: Teachers.change_teacher(teacher))
        |> put_flash(:info, "Teacher info updated successfully!")
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(teacher_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event("teacher_updation_leave", %{"teacher" => params}, %{assigns: %{teacher: teacher}} = socket) do

    case Teachers.update_teacher(teacher, Map.put(params, "is_leaving", true)) do
      {:ok, teacher} ->
        socket
        |> assign(teacher: teacher)
        |> assign(teacher_changeset: Teachers.change_teacher(teacher))
        |> put_flash(:info, "Teacher info updated successfully!")
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(teacher_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event("teacher_validation", %{"teacher" => params}, %{assigns: %{teacher: teacher}} = socket) do
    teacher_changeset = Teachers.change_teacher(teacher, params) |> Map.put(:action, :insert)

    socket
    |> assign(teacher_changeset: teacher_changeset)
    |> noreply()
  end

  @impl true
  def handle_event("re_avtive_teacher", _, %{assigns: %{teacher: teacher}} = socket) do
    {:ok, teacher} = Teachers.update_teacher(teacher, %{"is_leaving" => nil, "leaving_certificate_date" => nil, "last_attendance_date" => nil})

    socket
    |> assign(teacher: teacher)
    |> assign(teacher_changeset: Teachers.change_teacher(teacher))
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        <div class="flex justify-between items-center mb-10">
          <div class="flex items-center">
            <h1 class="font-bold text-3xl">Miss <%= @teacher.name %></h1>
            <span :if={@teacher.is_leaving} class="ml-2 text-xs p-0.5 px-1 border bg-red-200 rounded-lg">non-active</span>
          </div>
          <div class="flex gap-1 ml-2">
            <.button
              class={""}
              icon="hero-pencil"
              phx-click={show_modal("edit_teacher")}
              phx-value-teacher_id={@teacher.id}
            />
            <.button
              class={""}
              icon="hero-trash"
              phx-click={JS.push("delete_teacher_id") |> show_modal("update_teacher_#{@teacher.id}")}
              phx-value-teacher_id={@teacher.id}
            />
            <%= if !@teacher.is_leaving do %>
              <.button
                class={""}
                phx-click={show_modal("teacher_leaving")}
              >
                Is Leaving?
              </.button>
            <% else %>
              <.button
                class={""}
                phx-click="re_avtive_teacher"
              >
                Re-active
              </.button>
            <% end %>
          </div>
        </div>
        <div class="grid grid-cols-2 p-5 border rounded-lg mt-5 gap-2">
          <div class="border p-2">
            <b class="capitalize">
              Registration Number:
            </b>
            <%= @teacher.registration_number %>
          </div>
          <div class="border p-2">
            <b class="capitalize">
              Father Name:
            </b>
            <%= @teacher.father_name %>
          </div>
          <div class="border p-2">
            <b class="capitalize">
              Address:
            </b>
            <%= @teacher.address %>
          </div>
          <div class="border p-2">
            <b class="capitalize">
              Education:
            </b>
            <%= @teacher.education %>
          </div>
          <div class="border p-2">
            <b class="capitalize">
              CNIC:
            </b>
            <%= @teacher.cnic %>
          </div>
          <div class="border p-2">
            <b class="capitalize">
              Whatsapp Number:
            </b>
            <%= @teacher.whatsapp_number %>
          </div>
          <div class="border p-2">
            <b class="capitalize">
              Sim Number:
            </b>
            <%= @teacher.sim_number %>
          </div>
          <div class="border p-2">
            <b class="capitalize">
              Registration Date:
            </b>
            <%= @teacher.registration_date %>
          </div>
          <%= if @teacher.is_leaving do %>
            <div class="border p-2">
              <b class="capitalize">
                Leaving Cer. Date:
              </b>
              <%= @teacher.leaving_certificate_date %>
            </div>
            <div class="border p-2">
              <b class="capitalize">
                Last Attendance:
              </b>
              <%= @teacher.last_attendance_date %>
            </div>
          <% end %>
        </div>
        <.modal id={"edit_teacher"}>
          <.form
            :let={f}
            for={@teacher_changeset}
            phx-change="teacher_validation"
            phx-submit="teacher_updation"
          >
            <.input field={f[:name]} type="text" label="Name" />
            <.input field={f[:father_name]} type="text" label="Father Name" />
            <.input field={f[:whatsapp_number]} type="text" label="Whatsapp Number" />
            <.input field={f[:sim_number]} type="text" label="Sim Number" />
            <.input field={f[:address]} type="text" label="Address" />
            <.input field={f[:education]} type="text" label="Education" />
            <.input field={f[:cnic]} type="text" label="CNIC" />

            <.button class="mt-5">Submit</.button>
          </.form>
        </.modal>
        <.modal id={"teacher_leaving"}>
          <.form
            :let={f}
            for={@teacher_changeset}
            phx-submit="teacher_updation_leave"
          >
            <.input field={f[:leaving_certificate_date]} type="date" label="Leaving Cer. Date" />
            <.input field={f[:last_attendance_date]} type="date" label="Last Attendance" />

            <.button class="mt-5">Submit</.button>
          </.form>
        </.modal>
        <%!-- <div class="p-2 mt-2">
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
            </div> --%>
      </div>
    """
  end
end
