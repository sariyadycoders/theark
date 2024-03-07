defmodule TheArkWeb.StudentFinanceLive do
  use TheArkWeb, :live_view

  alias TheArk.Students
  alias TheArk.Finances

  @impl true
  def mount(%{"id" => student_id}, _, socket) do
    student_name = Students.get_student_name(student_id)

    socket
    |> assign(student_name: student_name)
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
        <h1 class="font-bold text-3xl">Transactions for <%= @student_name %></h1>
        <div><b>Total Amount Due: </b> <%= @due_amount %> Rs.</div>
      </div>
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
            <.input
              field={f[:title]}
              type="select"
              label="Filter by Title"
              options={[
                "All",
                "Books",
                "Copies",
                "Monthly Fee",
                "Paper Fund",
                "Anual Charges",
                "Tour Fund",
                "Party Fund",
                "Registration Fee",
                "Admission Fee",
                "Remainings"
              ]}
            />
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

      <div class="grid grid-cols-7 items-center border-b-4 pb-2 font-bold text-lg mb-2">
        <div class="pl-4">
          T. ID
        </div>
        <div>
          T. Date
        </div>
        <div>
          No. of Payments
        </div>
        <div class="col-span-3">
          Details
        </div>
        <div>
          Status
        </div>
      </div>

      <%= for {finance, index} <- Enum.with_index(@finances) do %>
        <div class="grid grid-cols-7 items-center my-2">
          <div>
            <b><%= index + 1 %></b> | <%= finance.transaction_id %>
          </div>
          <div>
            <%= finance.inserted_at |> DateTime.to_string() %>
          </div>
          <div class="pl-16">
            <%= Enum.count(finance.transaction_details) %>
          </div>
          <div class="col-span-3">
            <%= for detail <- finance.transaction_details do %>
              <div class="flex items-center">
                <div class="mr-1"><b>Title:</b> <%= detail.title %></div>
                |
                <div class="mx-1"><b>T. Amount:</b> <%= detail.total_amount %></div>
                |
                <div class="mx-1"><b>Paid:</b> <%= detail.paid_amount %></div>
                |
                <div class="ml-1"><b>Due:</b> <%= detail.due_amount %></div>
              </div>
            <% end %>
          </div>
          <div>
            <span class={"p-1 rounded-md #{if get_status(finance) == "due", do: "bg-red-300", else: "bg-green-300"}"}><%= get_status(finance) %> </span>
          </div>
        </div>
        <hr />
      <% end %>
    </div>
    """
  end

  def get_status(finance) do
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
