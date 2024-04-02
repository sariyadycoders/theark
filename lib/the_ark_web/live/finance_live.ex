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

  @impl true
  def mount(_, _, socket) do
    students_finances = Finances.list_finances_of_students()

    socket
    |> assign(students_finances: students_finances)
    |> assign(is_bill: true)
    |> assign(group_id: nil)
    |> assign(edit_note_id: 0)
    |> assign(edit_finance_id: 0)
    |> assign(group: nil)
    |> assign(finance_params: nil)
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
    |> assign_finances()
    |> assign_total_paid()
    |> assign_total_due()
    |> ok
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
          <.finances_entries {assigns} />
        </div>
      </div>

      <h1 class="font-bold text-2xl mby-5">Total Student's Finances Calculations</h1>
      <div class="grid grid-cols-2 gap-5 mt-5 pl-5">
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
            <%= @total_due %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp assign_total_paid(%{assigns: %{students_finances: finances}} = socket) do
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

  defp assign_total_due(%{assigns: %{students_finances: finances}} = socket) do
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
    |> assign(total_due: total_paid)
  end

  @impl true
  defdelegate handle_event(event, unsigned_params, socket), to: TheArkWeb.StudentFinanceLive
end
