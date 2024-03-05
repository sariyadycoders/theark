defmodule TheArkWeb.StudentFinanceLive do
  use TheArkWeb, :live_view

  alias TheArk.Students

  @impl true
  def mount(%{"id" => student_id}, _, socket) do
    student = Students.get_student_for_finance(student_id)

    socket
    |> assign(student: student)
    |> assign(due_amount: calculate_total_due_amout(student.finances))
    |> ok
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex justify-between items-center">
        <h1 class="font-bold text-3xl mb-5">Transactions for <%= @student.name %></h1>
        <div><b>Total Amount Due: </b> <%= @due_amount %> Rs.</div>
      </div>
      <div class="grid grid-cols-5 gap-3">
        <%= for finance <- @student.finances do %>
          <div class="border rounded-lg p-4">
            <div>
              <div><b>T. ID: </b><%= finance.transaction_id %></div>
              <div><b>T. Date: </b><%= finance.inserted_at |> DateTime.to_string() %></div>
            </div>
            <div class="my-2 font-bold text-lg">
              Transction Details
            </div>
            <%= for detail <- finance.transaction_details do %>
              <div class="border my-2 p-2">
                <div><b>Title:</b> <%= detail.title %></div>
                <div><b>Total Amount:</b> <%= detail.total_amount %></div>
                <div><b>Paid:</b> <%= detail.paid_amount %></div>
                <div><b>Due:</b> <%= detail.due_amount %></div>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp calculate_total_due_amout(finances) do
    Enum.map(finances, fn fin ->
      Enum.map(fin.transaction_details, fn detail ->
        detail.due_amount
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end
end
