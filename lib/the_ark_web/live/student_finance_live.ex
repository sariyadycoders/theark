defmodule TheArkWeb.StudentFinanceLive do
  use TheArkWeb, :live_view
  use Timex

  import Ecto.Changeset
  import Phoenix.HTML.Form

  alias TheArk.{
    Finances,
    Finances.Finance,
    Serials,
    Groups,
    Notes,
    Notes.Note
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
  def mount(%{"id" => id}, _, socket) do
    group = Groups.get_group!(id)

    socket
    |> assign(options: @options)
    |> assign(
      finance_changeset: Finances.change_finance(%Finance{}, %{transaction_details: [%{}]})
    )
    |> assign(finance_params: nil)
    |> assign(is_bill: false)
    |> assign(collapsed_sections: [])
    |> assign(edit_note_id: 0)
    |> assign(edit_finance_id: 0)
    |> assign(group: group)
    |> assign(group_name: group.name)
    |> assign(group_id: String.to_integer(id))
    |> assign(note_changeset: Notes.change_note(%Note{}))
    |> assign(title: "All")
    |> assign(type: "All")
    |> assign(sort: "Descending")
    |> assign(t_id: "")
    |> assign_finances()
    |> assign_total_due_amout()
    |> ok
  end

  def handle_event("prind_reciept", %{"finance_id" => id}, socket) do
    socket
    |> redirect(to: "/reciept/#{String.to_integer(id)}")
    |> noreply()
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
      if !Map.get(finance_params, "is_bill") do
        put_change(
          finance_changeset,
          :group_id,
          Map.get(finance_params, "group_id") |> String.to_integer()
        )
      else
        put_change(
          finance_changeset,
          :is_bill,
          true
        )
      end

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
        |> then(fn socket ->
          if !Map.get(finance_params, "is_bill") do
            socket
            |> assign_finances()
          else
            socket
          end
        end)
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
  def handle_event(
        "update_finance",
        %{
          "finance" => _finance_params
        } = _params,
        %{assigns: %{finance_changeset: finance_changeset}} = socket
      ) do
    case Finances.update_finance(finance_changeset) do
      {:ok, _finance} ->
        socket
        |> put_flash(:info, "Transaction successfully updated!")
        |> assign(
          finance_changeset: Finances.change_finance(%Finance{}, %{transaction_details: [%{}]})
        )
        |> assign_finances()
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
        %{assigns: %{group_id: group_id}} = socket
      ) do
    Finances.delete_finance_by_id(id)

    socket
    |> assign_finances()
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
    |> assign(edit_finance_id: String.to_integer(id))
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
        %{assigns: %{group_id: group_id, is_bill: is_bill}} = socket
      ) do
    sort = if order == "Descending", do: "desc", else: "asc"
    t_id = "-" <> t_id
    finances = Finances.get_finances_for_group(is_bill, group_id, title, type, sort, t_id)

    socket
    |> assign(finances: finances)
    |> noreply()
  end

  @impl true
  def handle_event(
        "add_note",
        %{"note" => params, "finance_id" => id},
        %{assigns: %{group_id: group_id}} = socket
      ) do
    case Notes.create_note(Map.put(params, "finance_id", id)) do
      {:ok, _} ->
        socket
        |> put_flash(:info, "Note added successfully!")
        |> assign(note_changeset: Notes.change_note(%Note{}))
        |> assign_finances()
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(note_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event("validate_note", %{"note" => params}, socket) do
    socket
    |> assign(note_changeset: Notes.change_note(%Note{}, params))
    |> noreply()
  end

  @impl true
  def handle_event(
        "collapse",
        %{"section_id" => id},
        %{
          assigns: %{collapsed_sections: collapsed_sections, finance_changeset: finance_changeset}
        } = socket
      ) do
    collapsed_sections =
      if id in collapsed_sections,
        do: collapsed_sections -- [id],
        else: collapsed_sections ++ [id]

    socket
    |> assign(collapsed_sections: collapsed_sections)
    |> assign(finance_changeset: finance_changeset)
    |> noreply()
  end

  def handle_event("edit_note_id", %{"note_id" => id}, socket) do
    note = Notes.get_note!(id)
    changeset = Notes.change_note(note)

    socket
    |> assign(note_changeset: changeset)
    |> assign(edit_note_id: String.to_integer(id))
    |> noreply()
  end

  @impl true
  def handle_event(
        "edit_note",
        %{"note" => params, "note_id" => id},
        %{assigns: %{group_id: group_id}} = socket
      ) do
    note = Notes.get_note!(id)

    case Notes.update_note(note, params) do
      {:ok, _} ->
        socket
        |> put_flash(:info, "Note updated successfully!")
        |> assign(note_changeset: Notes.change_note(%Note{}))
        |> assign_finances()
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(note_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event(
        "delete_note",
        %{"note_id" => id},
        %{assigns: %{group_id: group_id}} = socket
      ) do
    Notes.delete_note_by_id(id)

    socket
    |> put_flash(:info, "Note deleted successfully!")
    |> assign_finances()
    |> noreply()
  end

  @impl true
  def handle_event("empty_note", _unsigned_params, socket) do
    socket
    |> assign(note_changeset: Notes.change_note(%Note{}))
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex justify-between items-center">
        <h1 class="font-bold text-3xl">
          Transactions for <%= @group_name %> <%= if !String.ends_with?(@group_name, "roup") and
                                                       @group.is_main,
                                                     do: "Group" %>
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
          <.finance_form_fields form={f} group={@group} is_bill={@is_bill} options={@options} />
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

      <.finances_entries {assigns} />
    </div>
    """
  end

  def finances_entries(assigns) do
    ~H"""
    <div class="grid grid-cols-12 items-center border-b-4 pb-2 font-bold text-lg mb-2">
      <div class="pl-8
         col-span-2">
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
        <div class="col-span-2 flex items-center gap-2">
          <div
            phx-click="collapse"
            phx-value-section_id={"notes_#{finance.id}"}
            class="cursor-pointer"
          >
            <.icon name="hero-arrows-up-down" class="w-6 h-6" />
          </div>
          <div><b><%= index + 1 %></b> | <%= finance.transaction_id %></div>
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
          <span class={"p-1 rounded-full w-5 h-5 #{if get_status(finance) == "due", do: "bg-red-700", else: "bg-green-700"}"}>
            <%!-- <%= get_status(finance) %> --%>
          </span>
          <div class="flex gap-1">
            <.icon_button
              icon="hero-pencil"
              phx-click={
                JS.push("assign_changeset") |> show_modal("edit_student_finance_#{finance.id}")
              }
              phx-value-finance_id={finance.id}
            />
            <.icon_button icon="hero-trash" phx-click="delete" phx-value-finance_id={finance.id} />
            <.icon_button
              icon="hero-document-text"
              phx-click="prind_reciept"
              phx-value-finance_id={finance.id}
            />
            <.icon_button
              icon="hero-plus"
              phx-click={JS.push("empty_note") |> show_modal("add_note_#{finance.id}")}
            />
          </div>
        </div>
      </div>

      <div
        :if={"notes_#{finance.id}" in @collapsed_sections}
        class="border rounded-lg my-3 flex items-center"
      >
        <div class="flex flex-col gap-2 p-5">
          <%= for note <- finance.notes do %>
            <div>
              <span class="font-bold capitalize gap-2"><%= note.title %>:</span>
              <span><%= note.description %></span>
              <span>[Date: <%= Calendar.strftime(note.updated_at, "%d %B, %Y - %I:%M %P") %>]</span>
              <span
                phx-click={JS.push("edit_note_id") |> show_modal("edit_note_#{note.id}")}
                phx-value-note_id={note.id}
                class="cursor-pointer"
              >
                <.icon name="hero-pencil" class="h-4 w-4" />
              </span>
              <span phx-click="delete_note" phx-value-note_id={note.id} class="cursor-pointer">
                <.icon name="hero-trash" class="h-4 w-4" />
              </span>
            </div>
            <.modal id={"edit_note_#{note.id}"}>
              <%= if @edit_note_id == note.id do %>
                <.form
                  :let={f}
                  for={@note_changeset}
                  phx-submit="edit_note"
                  phx-value-note_id={note.id}
                >
                  <.input field={f[:title]} type="text" label="Title" />
                  <.input field={f[:description]} type="textarea" label="Important Note" />

                  <.button class="mt-5">Add</.button>
                </.form>
              <% end %>
            </.modal>
          <% end %>
          <span :if={Enum.count(finance.notes) == 0}>No notes available for this finance</span>
        </div>
      </div>

      <hr />
      <.modal id={"add_note_#{finance.id}"}>
        <.form
          :let={f}
          for={@note_changeset}
          phx-submit="add_note"
          phx-change="validate_note"
          phx-value-finance_id={finance.id}
        >
          <.input field={f[:title]} type="text" label="Title" />
          <.input field={f[:description]} type="textarea" label="Important Note" />

          <.button class="mt-5">Add</.button>
        </.form>
      </.modal>
      <.modal id={"edit_student_finance_#{finance.id}"}>
        <.form
          :let={f}
          for={@finance_changeset}
          phx-change="finance_validate_for_edit"
          phx-submit="update_finance"
          phx-value-finance_id={finance.id}
        >
          <%= if @edit_finance_id == finance.id do %>
            <.finance_form_fields form={f} group={@group} is_bill={@is_bill} options={@options} />
          <% end %>
          <div class="flex justify-end mt-5">
            <.button class="text-xs h-7" type="button" phx-click="add_more_detail">
              Add one more detail
            </.button>
          </div>

          <div class="flex gap-2 mt-5">
            <.button class="" type="submit">Submit</.button>
          </div>
        </.form>
      </.modal>
    <% end %>
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

  def assign_finances(
        %{
          assigns: %{
            title: title,
            type: type,
            sort: sort,
            t_id: t_id,
            is_bill: is_bill,
            group_id: group_id
          }
        } = socket
      ) do
    sort = if sort == "Descending", do: "desc", else: "asc"
    finances = Finances.get_finances_for_group(is_bill, group_id, title, type, sort, t_id)

    socket
    |> assign(finances: finances)
  end

  def finance_form_fields(assigns) do
    assigns =
      assigns
      |> Enum.into(%{is_bill: false})

    ~H"""
    <%= if !@is_bill do %>
      <.input field={@form[:group_id]} type="hidden" value={@group.id} />
    <% end %>
    <%= if @is_bill do %>
      <.input field={@form[:is_bill]} type="hidden" value="true" />
    <% end %>
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
          main_class={if input_value(n, :title) not in ["Monthly Fee", "Rent"], do: "hidden"}
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
