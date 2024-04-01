defmodule TheArkWeb.GroupsLive do
  use TheArkWeb, :live_view

  alias TheArk.Groups
  alias TheArk.Students
  alias Phoenix.LiveView.Components.MultiSelect


  @impl true
  def mount(_, _, socket) do
    groups = list_groups()

    socket
    |> assign(groups: groups)
    |> assign(group_changeset: Groups.change_group(%TheArk.Groups.Group{}))
    |> assign(options: [])
    |> assign(group_edit_id: 0)
    |> ok
  end

  @impl true
  def handle_info({:updated_options, options}, socket) do
    IO.inspect options

    socket
    |> assign(options: options)
    |> noreply()
  end

  def handle_event("edit_data", %{"group_id" => id}, socket) do
    group = Groups.get_group!(id)
    options = Enum.map(group.students, fn student ->
      %{id: student.id, label: student.name <> " " <> student.father_name <> " " <> " " <> "(#{student.class.name})", selected: true}
    end)

    socket
    |> assign(group_changeset: Groups.change_group(group))
    |> assign(group_edit_id: String.to_integer(id))
    |> assign(options: options)
    |> noreply()
  end

  def handle_event("assign_empty_changeset_of_group", _unsigned_params, socket) do
    socket
    |> assign(group_changeset: Groups.change_group(%TheArk.Groups.Group{}))
    |> noreply()
  end

  def handle_event("submit_group", %{"group" => params}, socket) do
    case Groups.create_group(params) do
      {:ok, _group} ->
        socket
        |> put_flash(:info, "Group Created Successfully!")
        |> assign(groups: list_groups())
        |> assign(group_changeset: Groups.change_group(%TheArk.Groups.Group{}))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(group_changeset: changeset)
        |> noreply()
    end
  end

  def handle_event("show_finances", %{"group_id" => id}, socket) do

    socket
    |> redirect(to: "/groups/#{String.to_integer(id)}/finances")
    |> noreply()
  end

  def handle_event("submit_group_edit", %{"group" => params, "group_id" => group_id}, %{assigns: %{options: options}} = socket) do

    group = Groups.get_group!(group_id)

    case Groups.update_group(group, params) do
      {:ok, _} ->
        non_selected_student_ids = Enum.filter(options, fn option ->
          !option.selected
        end)
        |> Enum.map(fn option ->
          option.id
        end)

        for id <- non_selected_student_ids do
          student = Students.get_student!(id)
          Students.update_student(student, %{group_id: student.first_group_id})
        end

        socket
        |> put_flash(:info, "Group Successfully updated!")
        |> assign(groups: list_groups())
        |> assign(options: [])
        |> noreply()
      {:error, changeset} ->
        socket
        |> assign(group_changeset: changeset)
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
      <div class="flex items-center gap-5 justify-between">
        <h1 class="font-bold text-3xl mb-5">The Ark Groups</h1>
        <.button phx-click={JS.push("assign_empty_changeset_of_group") |> show_modal("create_group")}>
          Create New Group
        </.button>
      </div>
      <.modal id="create_group">
        <.form :let={f} for={@group_changeset} phx-submit="submit_group">
          <.input field={f[:name]} type="text" label="Name of Group" />
          <.input field={f[:monthly_fee]} type="number" label="Monthly Fee" />
          <.input field={f[:is_main]} type="hidden" value="true" />

          <.button>Submit</.button>
        </.form>
      </.modal>
      <div class="grid grid-cols-7 items-center border-b-4 pb-2 font-bold text-lg mb-2 mt-5">
        <div>
          Name
        </div>
        <div class="text-center">
          No. of Students
        </div>
        <div class="col-span-2">
          Students
        </div>
        <div class="text-center">
          Monthly Fee
        </div>
        <div>
          Status
        </div>
        <div class="">
          Actions
        </div>
      </div>
      <%= for group <- @groups do %>
        <div
          class="grid grid-cols-7 items-center border-b py-2"
        >
          <div class="">
            <div class="flex items-center">
              <a class="capitalize"><%= group.name %> <%= if !String.ends_with?(group.name, "roup") and group.is_main, do: "Group" %></a>
              <span :if={false} class="ml-2 text-xs p-0.5 px-1 border bg-red-200 rounded-lg">
                non-active
              </span>
            </div>
          </div>
          <div class="text-center">
            <%= Enum.count(group.students) %>
          </div>
          <div class="col-span-2 flex flex-wrap">
            <%= for {student, index} <- Enum.with_index(group.students) do %>
              <a href={"/students/#{student.id}"} class="mr-1.5 capitalize"><%= student.name <> " " <> student.father_name %> <%= if index + 1 < Enum.count(group.students), do: "|" %></a>
            <% end %>
          </div>
          <div class="text-center">
            <%= group.monthly_fee %>
          </div>
          <div>
            <span class={"p-1 rounded-md #{if get_status(group) == "due", do: "bg-red-300", else: "bg-green-300"}"}>
              <%= get_status(group) %>
            </span>
          </div>
          <div class="flex gap-1">
            <.button phx-click="show_finances" phx-value-group_id={group.id} icon="hero-eye" />
            <.button phx-click={JS.push("edit_data") |> show_modal("edit_group_#{group.id}")} phx-value-group_id={group.id} icon="hero-pencil" />
          </div>
          <.modal id={"edit_group_#{group.id}"}>
            <.form :let={f} for={@group_changeset} phx-value-group_id={group.id} phx-submit="submit_group_edit">
              <%= if @group_edit_id == group.id do %>
                <.input field={f[:name]} type="text" label="Name of Group" />
                <.input field={f[:monthly_fee]} type="number" label="Monthly Fee" />
                <MultiSelect.multi_select
                  id={"students_#{group.id}"}
                  on_change={fn opts -> send(self(), {:updated_options, opts}) end}
                  form={f}
                  options={@options}
                  placeholder="Select Students..."
                  title="Select Students"
                />
              <% end %>

              <.button class="mt-10">Submit</.button>
            </.form>
          </.modal>
        </div>
      <% end %>
    </div>
    """
  end

  defp group_due?(group) do
    Enum.all?(group.finances, fn finance ->
      Enum.all?(finance.transaction_details, fn detail ->
        detail.total_amount == detail.paid_amount
      end)
    end)
  end

  defp get_status(group) do
    if group_due?(group) do
      "paid"
    else
      "due"
    end
  end

  defp list_groups() do
    Groups.list_groups()
    |> Enum.sort_by(fn group ->
      group_due?(group)
    end)
  end
end
