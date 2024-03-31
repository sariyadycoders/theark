defmodule TheArkWeb.StudentFinanceLive do
  use TheArkWeb, :live_view
  use Timex

  import Ecto.Changeset
  import TheArkWeb.StudentsShowLive, only: [finance_form_fields: 1]

  alias TheArk.{
    Students,
    Finances,
    Finances.Finance,
    Serials
  }

  @options [
    "All",
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
    student = Students.get_student_for_finance(student_id)

    socket
    |> assign(options: @options)
    |> assign(
      finance_changeset: Finances.change_finance(%Finance{}, %{transaction_details: [%{}]})
    )
    |> assign(finance_params: nil)
    |> assign(student: student)
    |> assign(student_name: student.name)
    |> assign(class: student.class.name)
    |> assign(student_id: String.to_integer(student_id))
    |> assign(title: "All")
    |> assign(type: "All")
    |> assign(sort: "Descending")
    |> assign(t_id: "")
    |> assign_finances(String.to_integer(student_id))
    |> assign_total_due_amout()
    |> ok
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
        |> assign_finances(finance.student_id)
        |> assign(finance_params: nil)
        |> then(fn socket ->
          if Map.get(finance_params, "is_print") == "true" do
            socket
            |> redirect(to: "/reciept/#{finance.id}")
          else
            socket
          end
        end)
        |> noreply()

      {:error, changeset} ->
        socket
        |> put_flash(:error, "Please fill details of transaction")
        |> assign(finance_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event(
        "update_finance",
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

    case Finances.update_finance(finance_changeset) do
      {:ok, finance} ->
        socket
        |> put_flash(:info, "Transaction successfully updated!")
        |> assign(
          finance_changeset: Finances.change_finance(%Finance{}, %{transaction_details: [%{}]})
        )
        |> assign_finances(finance.student_id)
        |> assign(finance_params: nil)
        |> then(fn socket ->
          if Map.get(finance_params, "is_print") == "true" do
            socket
            |> redirect(to: "/reciept/#{finance.id}")
          else
            socket
          end
        end)
        |> noreply()

      {:error, changeset} ->
        socket
        |> put_flash(:error, "Please fill details of transaction")
        |> assign(finance_changeset: changeset)
        |> noreply()
    end
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
        "finance_validate_for_edit",
        %{"finance_id" => id, "finance" => finance_params} = _params,
        socket
      ) do
    finance = Finances.get_finance!(id)
    finance_changeset = Finances.change_finance(finance, finance_params)

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
        "delete",
        %{"finance_id" => id},
        %{assigns: %{student_id: student_id}} = socket
      ) do
    Finances.delete_finance_by_id(id)

    socket
    |> assign_finances(student_id)
    |> noreply()
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
  def handle_event("assign_changeset", %{"finance_id" => id}, socket) do
    finance = Finances.get_finance!(id)

    socket
    |> assign(finance_changeset: Finances.change_finance(finance))
    |> noreply()
  end

  @impl true
  def handle_event(
        "filter_finances",
        %{
          "filter_finances" => %{
            "t_id" => t_id,
            "title" => title,
            "type" => type,
            "order" => order
          }
        },
        %{assigns: %{student_id: student_id}} = socket
      ) do
    sort = if order == "Descending", do: "desc", else: "asc"
    t_id = "-" <> t_id
    finances = Finances.get_finances_for_student(student_id, title, type, sort, t_id)

    socket
    |> assign(finances: finances)
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex justify-between items-center">
        <h1 class="font-bold text-3xl">
          Transactions for <%= @student_name %> of Class <%= @class %>
        </h1>
        <div class="flex items-center gap-2">
          <div><b>Total Amount Due: </b> <%= @due_amount %> Rs.</div>
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
          <.finance_form_fields form={f} student={@student} options={@options} />
          <div class="flex justify-end mt-5">
            <.button class="text-xs h-7" type="button" phx-click="add_more_detail">
              Add one more detail
            </.button>
          </div>
          <.button class="mt-5" type="submit">Submit Finance</.button>
        </.form>
      </.modal>
      <div class="my-5 border rounded-lg px-3 pb-3">
        <.form
          :let={f}
          for={}
          as={:filter_finances}
          class="flex items-center gap-3 justify-between"
          phx-change="filter_finances"
        >
          <div>
            <.input field={f[:t_id]} type="number" label="Search by T. ID" placeholder="e.g. 12345" />
          </div>
          <div class="flex items-center gap-3">
            <.input field={f[:title]} type="select" label="Filter by Title" options={@options} />
            <.input
              field={f[:type]}
              type="select"
              label="Filter by Type"
              options={["All", "Only Due", "Only Paid"]}
            />
            <.input
              field={f[:order]}
              type="select"
              label="Sort by Date"
              options={["Descending", "Ascending"]}
            />
          </div>
        </.form>
      </div>

      <div class="grid grid-cols-12 items-center border-b-4 pb-2 font-bold text-lg mb-2">
        <div class="pl-4 col-span-2">
          T. ID
        </div>
        <div class="col-span-2">
          T. Date
        </div>
        <div class="text-center">
          #
        </div>
        <div class="col-span-5">
          Details
        </div>
        <div class="col-span-2">
          Status
        </div>
      </div>

      <%= for {finance, index} <- Enum.with_index(@finances) do %>
        <div class="grid grid-cols-12 items-center my-2">
          <div class="col-span-2">
            <b><%= index + 1 %></b> | <%= finance.transaction_id %>
          </div>
          <div class="col-span-2">
            <%= Calendar.strftime(finance.inserted_at, "%d %B, %Y - %I:%M %P") %>
          </div>
          <div class="text-center">
            <%= Enum.count(finance.transaction_details) %>
          </div>
          <div class="col-span-5">
            <%= for detail <- finance.transaction_details do %>
              <div class="flex items-center">
                <div class="mr-1">
                  <b>Title:</b> <%= if detail.title != "Monthly Fee",
                    do: detail.title,
                    else: "#{detail.month} Fee" %>
                </div>
                |
                <div class="mx-1"><b>T. Amount:</b> <%= detail.total_amount %></div>
                |
                <div class="mx-1"><b>Paid:</b> <%= detail.paid_amount %></div>
                |
                <div class="ml-1"><b>Due:</b> <%= detail.due_amount %></div>
              </div>
            <% end %>
          </div>
          <div class="flex items-center justify-between col-span-2">
            <span class={"p-1 rounded-md #{if get_status(finance) == "due", do: "bg-red-300", else: "bg-green-300"}"}>
              <%= get_status(finance) %>
            </span>
            <div class="flex gap-1">
              <.button
                icon="hero-pencil"
                phx-click={
                  JS.push("assign_changeset") |> show_modal("edit_student_finance_#{finance.id}")
                }
                phx-value-finance_id={finance.id}
              />
              <.button icon="hero-trash" phx-click="delete" phx-value-finance_id={finance.id} />
              <.button
                icon="hero-document-text"
                phx-click={JS.push("assign_changeset") |> show_modal("delete_class_modal")}
                phx-value-class_id={nil}
              />
            </div>
          </div>
        </div>
        <hr />
        <.modal id={"edit_student_finance_#{finance.id}"}>
          <.form
            :let={f}
            for={@finance_changeset}
            phx-change="finance_validate_for_edit"
            phx-submit="update_finance"
            phx-value-finance_id={finance.id}
          >
            <.finance_form_fields form={f} student={@student} options={@options} />
            <div class="flex justify-end mt-5">
              <.button class="text-xs h-7" type="button" phx-click="add_more_detail">
                Add one more detail
              </.button>
            </div>

            <div class="flex gap-2 mt-5">
              <.button class="" type="submit">Submit</.button>
              <.input main_class="pb-3 pl-2" field={f[:is_print]} label="Printing?" type="checkbox" />
            </div>
          </.form>
        </.modal>
      <% end %>
    </div>
    """
  end

  defp get_status(finance) do
    if Enum.all?(finance.transaction_details, fn detail ->
         detail.total_amount == detail.paid_amount
       end) do
      "paid"
    else
      "due"
    end
  end

  defp assign_total_due_amout(%{assigns: %{finances: finances}} = socket) do
    due_amount =
      Enum.map(finances, fn fin ->
        Enum.map(fin.transaction_details, fn detail ->
          detail.due_amount
        end)
        |> Enum.sum()
      end)
      |> Enum.sum()

    socket
    |> assign(due_amount: due_amount)
  end

  defp assign_finances(
         %{assigns: %{title: title, type: type, sort: sort, t_id: t_id}} = socket,
         student_id
       ) do
    sort = if sort == "Descending", do: "desc", else: "asc"
    finances = Finances.get_finances_for_student(student_id, title, type, sort, t_id)

    socket
    |> assign(finances: finances)
  end
end
