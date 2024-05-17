defmodule TheArkWeb.ClassSubmitFineLive do
  alias TheArk.Transaction_details
  use TheArkWeb, :live_view

  # TODO: Submission of fine

  @list_of_months ~w(Choose January February March April May June July August September October November December)

  @impl true
  def mount(%{"id" => class_id}, _session, socket) do
    socket
    |> assign(list_of_months: @list_of_months)
    |> assign(month_choosen: nil)
    |> assign(class_id: String.to_integer(class_id))
    |> assign_transactions()
    |> ok()
  end

  @impl true
  def handle_event("apply_filters", %{"filter" => %{"month" => "Choose"}}, socket) do
    socket
    |> assign(month_choosen: nil)
    |> assign_transactions()
    |> noreply()
  end

  @impl true
  def handle_event("apply_filters", %{"filter" => %{"month" => month}}, socket) do
    socket
    |> assign(month_choosen: month)
    |> assign_transactions()
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="px-5 pb-3 border rounded-lg my-5">
        <.form :let={f} for={} as={:filter} phx-change="apply_filters" class="flex justify-end">
          <.input field={f[:month]} label="Choose Month" type="select" options={@list_of_months} />
        </.form>
      </div>
      <div class="border-b-4 font-bold text-lg pb-1 my-5">
        Details of Students
      </div>
      <.form :let={f} for={} as={:submission} phx-submit="submit">
        <div class="grid grid-cols-2 gap-5">
          <div class="grid grid-cols-6 font-bold pb-1 border-b-2">
            <div class="col-span-2">Name</div>
            <div class="col-span-2">Date</div>
            <div>Pay</div>
            <div>Concession</div>
          </div>
          <div class="grid grid-cols-6 font-bold pb-1 border-b-2">
            <div class="col-span-2">Name</div>
            <div class="col-span-2">Date</div>
            <div>Pay</div>
            <div>Concession</div>
          </div>
          <%= for trans <- @transactions do %>
            <div class="grid grid-cols-6 my-2">
              <div class="col-span-2"><%= trans.name %></div>
              <div class="col-span-2"><%= trans.date |> Date.to_string() %></div>
              <div>Pay</div>
              <div>Concession</div>
            </div>
          <% end %>
        </div>
      </.form>
    </div>
    """
  end

  def assign_transactions(%{assigns: %{class_id: _class_id, month_choosen: nil}} = socket) do
    socket
    |> assign(transactions: [])
  end

  def assign_transactions(%{assigns: %{class_id: class_id, month_choosen: month}} = socket) do
    transactions = Transaction_details.get_absentee_due_students_for_submission(class_id, month)

    socket
    |> assign(transactions: transactions)
  end
end
