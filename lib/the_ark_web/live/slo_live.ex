defmodule TheArkWeb.SloLive do
  use TheArkWeb, :live_view

  alias TheArk.Classes
  alias TheArk.Slos
  alias TheArk.Slos.Slo

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    socket
    |> assign(class: Classes.get_class_for_slos(id))
    |> assign(slo_changeset: Slos.change_slo(%Slo{}))
    |> assign(edit_slo_id: 0)
    |> ok
  end

  @impl true
  def handle_event(
        "add_slo",
        %{"slo" => params},
        %{assigns: %{class: %{id: id}}} = socket
      ) do
    params = Map.merge(params, %{"class_id" => id})

    case Slos.create_slo(params) do
      {:ok, _slo} ->
        socket
        |> put_flash(:info, "Slo added!")
        |> assign(class: Classes.get_class_for_slos(id))
        |> assign(slo_changeset: Slos.change_slo(%Slo{}))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(slo_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event("assign_changeset", %{"slo_id" => slo_id}, socket) do
    slo = Slos.get_slo!(slo_id)
    changeset = Slos.change_slo(slo)

    socket
    |> assign(edit_slo_id: String.to_integer(slo_id))
    |> assign(slo_changeset: changeset)
    |> noreply()
  end

  @impl true
  def handle_event(
        "slo_edit",
        %{"slo" => params},
        %{assigns: %{edit_slo_id: slo_id, class: %{id: class_id}}} = socket
      ) do
    slo = Slos.get_slo!(slo_id)

    case Slos.update_slo(slo, params) do
      {:ok, _slo} ->
        socket
        |> put_flash(:info, "Slo updated!")
        |> assign(class: Classes.get_class_for_slos(class_id))
        |> assign(slo_changeset: Slos.change_slo(%Slo{}))
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(slo_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event(
        "slo_delete",
        %{"slo_id" => slo_id},
        %{assigns: %{class: %{id: class_id}}} = socket
      ) do
    Slos.delete_slo_by_id(slo_id)

    socket
    |> assign(class: Classes.get_class_for_slos(class_id))
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between">
        <h1 class="font-bold text-3xl mb-5">SLO's for Class <%= @class.name %></h1>
        <.button phx-click={show_modal("add_slo")}>Add SLO</.button>
      </div>
      <ol class="list-decimal ml-8">
        <%= for slo <- @class.slos do %>
          <li class="mb-2">
            <%= slo.description %>
            <div class="flex gap-2 items-center">
              <.button
                icon="hero-pencil"
                phx-click={JS.push("assign_changeset") |> show_modal("slo_edit_#{slo.id}")}
                phx-value-slo_id={slo.id}
              />
              <.button icon="hero-trash" phx-click="slo_delete" phx-value-slo_id={slo.id} />
            </div>
          </li>
          <.modal id={"slo_edit_#{slo.id}"}>
            <%= if @edit_slo_id == slo.id do %>
              <.form :let={f} for={@slo_changeset} phx-submit="slo_edit">
                <.input field={f[:description]} type="text" label="Description" />

                <.button class="mt-5">Add</.button>
              </.form>
            <% end %>
          </.modal>
        <% end %>
      </ol>

      <.modal id="add_slo">
        <.form :let={f} for={@slo_changeset} phx-submit="add_slo">
          <.input field={f[:description]} type="text" label="Description" />

          <.button class="mt-5">Add</.button>
        </.form>
      </.modal>
    </div>
    """
  end
end
