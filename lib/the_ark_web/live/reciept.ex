defmodule TheArkWeb.RecieptPrint do
  use TheArkWeb, :live_view

  alias TheArk.Finances

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    finance = Finances.get_finance_for_reciept(id)

    socket
    |> assign(finance: finance)
    |> assign(transaction_by: "Q. A. Maalik Mujahid")
    |> ok()
  end

  @impl true
  def handle_event("add_sign", %{"transaction_by" => %{"name" => name}}, socket) do
    socket
    |> assign(transaction_by: name)
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center">
      <div class="w-96 border-2 p-3">
        <div class="text-xl text-center font-bold">
          The Ark Montessori School System
        </div>
        <div class="text-xl text-center">
          RECIEPT
        </div>
        <div class="mt-2">
          <b>Transaction ID:</b> <%= @finance.transaction_id %>
        </div>
        <div class="">
          <b>Date:</b> <%= Calendar.strftime(@finance.updated_at, "%d %B, %Y - %I:%M %P") %>
        </div>
        <div class="p-2 border mt-2 text-sm">
          <div class="col-span-3">
            <b><%= if Enum.count(@finance.group.students) > 1, do: "Names", else: "Name" %>:</b>
            <%= for {student, index} <- Enum.with_index(@finance.group.students) do %>
              <span class="capitalize"><%= student.name %></span><span :if={
                (index + 1 < Enum.count(@finance.group.students))
              }>, </span>
            <% end %>
          </div>
          <div class="col-span-2">
            <b><%= if Enum.count(@finance.group.students) > 1, do: "Classes", else: "Class" %>:</b>
            <%= for {student, index} <- Enum.with_index(@finance.group.students) do %>
              <span><%= student.class.name %></span><span :if={
                (index + 1 < Enum.count(@finance.group.students))
              }>, </span>
            <% end %>
          </div>
        </div>
        <div class="mt-2 font-bold">Details:</div>
        <div class="grid grid-cols-6 font-bold text-sm pb-1 border-b-2">
          <div>#</div>
          <div class="col-span-2">Description</div>
          <div>Total</div>
          <div>Paid</div>
          <div>Due</div>
        </div>
        <%= for {detail, index} <- Enum.with_index(@finance.transaction_details) do %>
          <div class="grid grid-cols-6 text-sm py-1 border-b">
            <div><%= index + 1 %></div>
            <div class="col-span-2">
              <%= if detail.title != "Monthly Fee", do: detail.title, else: "#{detail.month} Fee" %>
            </div>
            <div><%= detail.total_amount %></div>
            <div><%= detail.paid_amount %></div>
            <div><%= detail.due_amount %></div>
          </div>
        <% end %>
        <div class="grid grid-cols-6 text-sm font-bold py-1 border-b">
          <div>Total</div>
          <div class="col-span-2"><%= "" %></div>
          <div><%= calculate_total_amount(@finance) %></div>
          <div><%= calculate_pain_amount(@finance) %></div>
          <div><%= calculate_due_amount(@finance) %></div>
        </div>
        <div class="mt-10 font-bold text-end">
          Sign: <span class="ml-2 underline"><%= @transaction_by %></span>
        </div>
      </div>

      <.form :let={f} for={} as={:transaction_by} phx-change="add_sign" class="mt-10">
        <.input
          main_class=""
          field={f[:name]}
          label="Transaction By"
          type="select"
          options={["Q. A. Maalik Mujahid", "Abu Bakr Younas", "Saaria Mujahid"]}
        />
      </.form>
    </div>
    """
  end

  def calculate_total_amount(finance) do
    Enum.map(finance.transaction_details, fn detail ->
      detail.total_amount
    end)
    |> Enum.sum()
  end

  def calculate_pain_amount(finance) do
    Enum.map(finance.transaction_details, fn detail ->
      detail.paid_amount
    end)
    |> Enum.sum()
  end

  def calculate_due_amount(finance) do
    Enum.map(finance.transaction_details, fn detail ->
      detail.due_amount
    end)
    |> Enum.sum()
  end
end
