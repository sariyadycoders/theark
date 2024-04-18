defmodule TheArkWeb.FinanceLive do
  use TheArkWeb, :live_view

  import TheArkWeb.StudentFinanceLive,
    only: [finance_form_fields: 1, assign_finances: 1, finances_entries: 1]

  alias TheArk.{
    Finances,
    Finances.Finance,
    Notes,
    Notes.Note
  }

  @student_finance_options [
    "All",
    "Books",
    "Monthly Fee",
    "1st Term Paper Fund",
    "2nd Term Paper Fund",
    "3rd Term Paper Fund",
    "Anual Charges",
    "Tour Fund",
    "Party Fund",
    "Registration Fee",
    "Admission Fee"
  ]

  @options [
    "Books",
    "Copies",
    "Utility Bills",
    "Rent",
    "Stationary",
    "Repairing",
    "Teacher Pay",
    "Function Expenses",
    "All"
  ]

  @month_options [
    "none",
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
  ]

  @impl true
  def mount(_, _, socket) do
    students_total_finances = Finances.list_finances_of_students()

    socket
    |> assign(student_finance_options: @student_finance_options)
    |> assign(students_total_finances: students_total_finances)
    |> assign(month_options: @month_options)
    |> assign(is_bill: true)
    |> assign(group_id: nil)
    |> assign(edit_note_id: 0)
    |> assign(edit_finance_id: 0)
    |> assign(group: nil)
    |> assign(finance_params: nil)
    |> assign(non_payee_type: "All")
    |> assign(month_choosen_for_non_payee_description: nil)
    |> assign(year_choosen_for_non_payee_description: Date.utc_today().year)
    |> assign(options: @options)
    |> assign(title: "All")
    |> assign(type: "All")
    |> assign(sort: "Descending")
    |> assign(t_id: "")
    |> assign(collapsed_sections: [])
    |> assign(note_changeset: Notes.change_note(%Note{}))
    |> assign(
      finance_changeset: Finances.change_finance(%Finance{}, %{transaction_details: [%{}]})
    )
    # having only bill
    |> assign_finances()
    |> assign_total_paid()
    |> assign_total_student_due()
    |> assign_due_bills()
    |> assign_detailed_description()
    |> ok
  end

  def handle_event(
        "choose_non_payee_description",
        %{"choose_filter" => %{"type" => type, "month" => month, "year" => year}},
        socket
      ) do
    socket
    |> assign(month_choosen_for_non_payee_description: month)
    |> assign(year_choosen_for_non_payee_description: String.to_integer(year))
    |> assign(non_payee_type: type)
    |> noreply()
  end

  def handle_event(
        "choose_non_payee_description",
        %{"choose_filter" => %{"type" => type, "year" => year}},
        socket
      ) do
    socket
    |> assign(non_payee_type: type)
    |> assign(year_choosen_for_non_payee_description: String.to_integer(year))
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between">
        <h1 class="font-bold text-3xl mb-5">Finances</h1>
        <.button phx-click={
          JS.push("assign_finance_empty_changeset") |> show_modal("add_student_finance_1")
        }>
          Add Bills
        </.button>
      </div>

      <.modal id="add_student_finance_1">
        <.form
          :let={f}
          for={@finance_changeset}
          phx-change="finance_validate"
          phx-submit="add_finance"
        >
          <.finance_form_fields form={f} group={@group} is_bill={@is_bill} options={@options} />
          <div class="flex justify-end mt-5">
            <.button class="text-xs h-7" type="button" phx-click="add_more_detail">
              Add one more detail
            </.button>
          </div>
          <.button class="mt-5" type="submit">Submit Finance</.button>
        </.form>
      </.modal>

      <div class="rounded-lg border border-4 p-5 mt-5">
        <h1 class="font-bold text-2xl">Total Finances Calculations</h1>
        <div class="grid grid-cols-4 gap-5 mt-5">
          <div class="rounded-lg border-2 p-5">
            <div>
              Total Income
            </div>
            <div class="text-5xl font-bold text-center">
              <%= @total_paid %>
            </div>
          </div>
          <div class="rounded-lg border-2 p-5">
            <div>
              Total Due from Students
            </div>
            <div class="text-5xl font-bold text-center">
              <%= @total_student_due %>
            </div>
          </div>
          <div class="rounded-lg border-2 p-5">
            <div>
              Total Due Bills
            </div>
            <div class="text-5xl font-bold text-center">
              <%= @due_bills %>
            </div>
          </div>
          <div class="rounded-lg border-2 p-5">
            <div>
              Net Due
            </div>
            <div class="text-5xl font-bold text-center">
              <%= @net_due %>
            </div>
          </div>
        </div>
      </div>

      <div class="border rounded-lg my-5">
        <div class="rounded-t-lg bg-gray-300 p-3 font-bold flex justify-between items-center">
          <div>Bills Description</div>
          <div phx-click="collapse" phx-value-section_id="bills" class="cursor-pointer">
            <.icon name="hero-arrows-up-down" class="w-6 h-6" />
          </div>
        </div>

        <div :if={"bills" in @collapsed_sections} class="flex flex-col p-5">
          <div class="my-5 border rounded-lg px-3 pb-3">
            <.form
              :let={f}
              for={}
              as={:filter_finances}
              class="flex items-center gap-3 justify-between"
              phx-change="filter_finances"
            >
              <div>
                <.input
                  field={f[:t_id]}
                  type="number"
                  label="Search by T. ID"
                  placeholder="e.g. 12345"
                />
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
          <div class="max-h-[400px] overflow-y-scroll">
            <.finances_entries {assigns} />
          </div>
        </div>
      </div>

      <div class="border rounded-lg my-5">
        <div class="rounded-t-lg bg-gray-300 p-3 font-bold flex justify-between items-center">
          <div>Non-Payee Students</div>
          <div phx-click="collapse" phx-value-section_id="students_fee" class="cursor-pointer">
            <.icon name="hero-arrows-up-down" class="w-6 h-6" />
          </div>
        </div>

        <div :if={"students_fee" in @collapsed_sections} class="flex flex-col p-5">
          <div class="flex justify-end p-2 rounded-lg border">
            <.form
              :let={f}
              for={}
              as={:choose_filter}
              phx-change="choose_non_payee_description"
              class="flex items-center justify-center gap-2"
            >
              <.input
                field={f[:type]}
                type="select"
                label="Choose type"
                options={@student_finance_options}
                main_class="!mt-0"
              />
              <%= if @non_payee_type == "Monthly Fee" do %>
                <.input
                  field={f[:month]}
                  type="select"
                  label="Choose month"
                  options={@month_options}
                  main_class="!mt-0"
                />
              <% end %>
              <% current_year = Date.utc_today().year %>
              <.input
                field={f[:year]}
                type="select"
                label="Choose Year"
                options={[current_year, current_year - 1, current_year - 2]}
                main_class="!mt-0"
              />
            </.form>
          </div>
          <div class="max-h-[400px] overflow-y-scroll">
            <%= for class <- @detailed_indiv_finances do %>
              <div
                :if={
                  Enum.count(
                    get_non_payee_students(
                      class,
                      @month_choosen_for_non_payee_description,
                      @year_choosen_for_non_payee_description,
                      @non_payee_type
                    )
                  ) > 0
                }
                class="my-5 rounded-lg border mx-8 p-5"
              >
                <div class="text-lg font-bold"><%= class.name %></div>
                <div class="grid grid-cols-3 border mt-5">
                  <%= for student <- get_non_payee_students(class, @month_choosen_for_non_payee_description, @year_choosen_for_non_payee_description, @non_payee_type) do %>
                    <div class="p-2 border capitalize">
                      <%= student.name <> " " <> student.father_name %>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>

      <div class="border rounded-lg my-5">
        <div class="rounded-t-lg bg-gray-300 p-3 font-bold flex justify-between items-center">
          <div>Students List (having Dues)</div>
          <div phx-click="collapse" phx-value-section_id="students_dues" class="cursor-pointer">
            <.icon name="hero-arrows-up-down" class="w-6 h-6" />
          </div>
        </div>

        <div :if={"students_dues" in @collapsed_sections} class="flex flex-col p-5">
          <div class="flex flex-col gap-5 max-h-[400px] overflow-y-scroll">
            <%= for class <- @detailed_indiv_finances do %>
              <div :if={Enum.count(get_students_having_dues(class)) > 0} class="rounded-lg border p-5">
                <div class="text-lg font-bold"><%= class.name %></div>
                <div class="grid grid-cols-3 border mt-5">
                  <%= for student <- get_students_having_dues(class) do %>
                    <div class="p-2 border capitalize">
                      <a href={"/groups/#{student.group_id}/finances"}>
                        <%= student.name <> " " <> student.father_name %>
                      </a>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp assign_total_paid(%{assigns: %{students_total_finances: finances}} = socket) do
    total_paid =
      Enum.filter(finances, fn finance ->
        !finance.is_bill
      end)
      |> Enum.map(fn finance ->
        Enum.map(finance.transaction_details, fn detail ->
          detail.paid_amount
        end)
        |> Enum.sum()
      end)
      |> Enum.sum()

    socket
    |> assign(total_paid: total_paid)
  end

  defp assign_total_student_due(%{assigns: %{students_total_finances: finances}} = socket) do
    total_paid =
      Enum.filter(finances, fn finance ->
        !finance.is_bill
      end)
      |> Enum.map(fn finance ->
        Enum.map(finance.transaction_details, fn detail ->
          detail.due_amount
        end)
        |> Enum.sum()
      end)
      |> Enum.sum()

    socket
    |> assign(total_student_due: total_paid)
  end

  defp assign_due_bills(
         %{assigns: %{finances: finances, total_student_due: total_student_due}} = socket
       ) do
    due_bills =
      Enum.map(finances, fn finance ->
        Enum.map(finance.transaction_details, fn detail ->
          detail.due_amount
        end)
        |> Enum.sum()
      end)
      |> Enum.sum()

    net_due = total_student_due - due_bills

    socket
    |> assign(due_bills: due_bills)
    |> assign(net_due: net_due)
  end

  defp assign_detailed_description(socket) do
    detailed_indiv_finances = Finances.detailed_indiv_finances()

    socket
    |> assign(detailed_indiv_finances: detailed_indiv_finances)
  end

  defp get_non_payee_students(
         class,
         month_choosen_for_non_payee_description,
         year_choosen_for_non_payee_description,
         "Monthly Fee"
       ) do
    Enum.reject(class.students, fn student ->
      Enum.any?(student.finances, fn finance ->
        Enum.any?(finance.transaction_details, fn detail ->
          detail.title == "Monthly Fee" and
            detail.month == month_choosen_for_non_payee_description and
            detail.inserted_at.year == year_choosen_for_non_payee_description and
            detail.due_amount == 0
        end)
      end)
    end)
  end

  defp get_non_payee_students(
         class,
         _month_choosen_for_non_payee_description,
         year_choosen_for_non_payee_description,
         non_payee_type
       ) do
    Enum.reject(class.students, fn student ->
      Enum.any?(student.finances, fn finance ->
        Enum.any?(finance.transaction_details, fn detail ->
          detail.title == non_payee_type and
            detail.inserted_at.year == year_choosen_for_non_payee_description and
            detail.due_amount == 0
        end)
      end)
    end)
  end

  defp get_students_having_dues(class) do
    Enum.reject(class.students, fn student ->
      Enum.all?(student.finances, fn finance ->
        Enum.all?(finance.transaction_details, fn detail ->
          detail.due_amount == 0
        end)
      end)
    end)
  end

  @impl true
  defdelegate handle_event(event, unsigned_params, socket), to: TheArkWeb.StudentFinanceLive
end
