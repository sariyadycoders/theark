defmodule TheArkWeb.StudentsShowLive do
  use TheArkWeb, :live_view

  import TheArkWeb.ClassResultLive,
    only: [
      get_total_marks_of_term_from_results: 2,
      get_obtained_marks_of_term_from_results: 2,
      get_percentage_of_marks: 2
    ]

  import Ecto.Changeset
  import Phoenix.HTML.Form

  alias TheArk.{
    Students,
    Classes,
    Students.Student,
    Finances,
    Finances.Finance,
    Serials
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
    socket
    |> assign(options: @options)
    |> assign(student: Students.get_student!(String.to_integer(student_id)))
    |> assign(
      finance_changeset: Finances.change_finance(%Finance{}, %{transaction_details: [%{}]})
    )
    |> assign(finance_params: nil)
    |> assign(class_options: Classes.get_class_options())
    |> assign(is_leaving_form_open: false)
    |> assign(surety_of_reactivation: false)
    |> assign(student_leaving_changeset: Students.change_student_leaving(%Student{}))
    |> assign(is_leaving_button: true)
    |> assign(term_name: nil)
    |> assign(transaction_details: %{})
    |> ok
  end

  @impl true
  def handle_event("assign_finance_empty_changeset", _, socket) do
    socket
    |> assign(
      finance_changeset: Finances.change_finance(%Finance{}, %{transaction_details: [%{}]})
    )
    |> noreply()
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

  @impl true
  def handle_event(
        "finance_validate",
        %{"finance" => finance_params} = _params,
        socket
      ) do
    finance_changeset = Finances.change_finance(%Finance{}, finance_params)

    socket
    |> assign(finance_changeset: finance_changeset)
    |> assign(finance_params: finance_params)
    |> noreply()
  end

  @impl true
  def handle_event(
        "add_more_detail",
        _unsigned_params,
        %{assigns: %{finance_params: finance_params}} = socket
      ) do
    if finance_params do
      {_, finance_params} =
        get_and_update_in(finance_params["transaction_details"], fn data ->
          no_of_details = length(Map.keys(data))

          new_key = no_of_details |> Integer.to_string()
          option = %{new_key => %{}}
          {option, Map.merge(data, option)}
        end)

      finance_changeset = Finances.change_finance(%Finance{}, finance_params)

      socket
      |> assign(finance_changeset: finance_changeset)
      |> noreply()
    else
      socket
      |> noreply()
    end
  end

  @impl true
  def handle_event(
        "add_finance",
        %{
          "finance" => finance_params
        } = _params,
        %{assigns: %{finance_changeset: finance_changeset}} = socket
      ) do
    finance_changeset =
      put_change(
        finance_changeset,
        :student_id,
        Map.get(finance_params, "student_id") |> String.to_integer()
      )

    case Finances.create_finance(finance_changeset) do
      {:ok, finance} ->
        serial = Serials.get_serial_by_name("finance")
        transaction_id = TheArkWeb.Home.generate_registration_number(serial.number)
        Serials.update_serial(serial, %{"number" => transaction_id})
        Finances.update_finance(finance, %{"transaction_id" => transaction_id})

        socket
        |> put_flash(:info, "Transaction successfully added!")
        |> assign(
          finance_changeset: Finances.change_finance(%Finance{}, %{transaction_details: [%{}]})
        )
        |> assign(finance_params: nil)
        |> noreply()

      {:error, changeset} ->
        socket
        |> put_flash(:error, "Please fill details of transaction")
        |> assign(finance_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event("go_to_finance", _unsigned_params, %{assigns: %{student: student}} = socket) do
    socket
    |> redirect(to: "/students/#{student.id}/finances")
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
          <.button phx-click="go_to_finance">
            See Finances
          </.button>
          <.button phx-click={
            JS.push("assign_finance_empty_changeset") |> show_modal("add_student_finance")
          }>
            Add Finance
          </.button>
        </div>
      </div>

      <.modal id="add_student_finance">
        <.form
          :let={f}
          for={@finance_changeset}
          phx-change="finance_validate"
          phx-submit="add_finance"
        >
          <.finance_form_fields form={f} options={@options} student={@student} />
          <div class="flex justify-end mt-5">
            <.button class="text-xs h-7" type="button" phx-click="add_more_detail">
              Add one more detail
            </.button>
          </div>

          <.button class="mt-5" type="submit">Submit Finance</.button>
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

  def finance_form_fields(assigns) do
    ~H"""
    <.input field={@form[:student_id]} type="hidden" value={@student.id} />
    <.inputs_for :let={n} field={@form[:transaction_details]}>
      <div class="grid grid-cols-4 gap-2 items-end">
        <.input
          field={n[:title]}
          label="Title"
          type="select"
          options={@options -- ["All"]}
          value={input_value(n, :title)}
        />
        <.input
          field={n[:month]}
          label="Month"
          type="select"
          options={[
            "Jan",
            "Feb",
            "Mar",
            "Apr",
            "May",
            "Jun",
            "Jul",
            "Aug",
            "Sep",
            "Oct",
            "Nov",
            "Dec"
          ]}
          value={input_value(n, :month)}
          main_class={if input_value(n, :title) != "Monthly Fee", do: "hidden"}
        />
        <.input
          field={n[:total_amount]}
          label="Total"
          type="number"
          value={input_value(n, :total_amount)}
        />
        <.input
          field={n[:paid_amount]}
          label="Paid"
          type="number"
          value={input_value(n, :paid_amount)}
        />
        <div class="col-span-4 flex justify-end">
          <.input
            main_class="pb-3 pl-2"
            field={n[:is_accected]}
            label="Is Accepted?"
            type="checkbox"
            value={input_value(n, :is_accected)}
          />
        </div>
      </div>
      <hr :if={true} class="mt-2" />
    </.inputs_for>
    """
  end
end
