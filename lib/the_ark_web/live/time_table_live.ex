defmodule TheArkWeb.TimeTableLive do
  use TheArkWeb, :live_view

  alias TheArk.Classes

  @impl true
  def mount(_, _, socket) do
    socket
    |> assign(classes: Classes.list_classes())
    |> assign(periods: [])
    |> ok
  end

  @impl true
  def handle_event("periods_creation",
    %{"periods_creation" => %{"number" => number, "start_time" => start_time, "end_time" => end_time}},
    socket) do

    periods = []

    {:ok, start_time} = Time.from_iso8601(start_time <> ":00")
    {:ok, end_time} = Time.from_iso8601(end_time <> ":00")

    time_difference = Time.diff(start_time, end_time)
    time_of_slot = (time_difference / String.to_integer(number)) |> round()

    periods =
      for number <- 1..String.to_integer(number) do
        periods ++ [%{"period_number" => number, "start_time" => Time.add(start_time, (time_of_slot)*(number-1)), "end_time" => Time.add(Time.add(start_time, (time_of_slot)*(number-1)), time_of_slot)}]
      end

    socket
    |> assign(periods: Enum.flat_map(periods, fn x -> x end))
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between">
        <h1 class="font-bold text-3xl my-5">Time Table</h1>
        <.button phx-click={show_modal("periods_management")}>Create or Edit Periods</.button>
      </div>
      <div class="border rounded-lg my-5 p-5">
        time table
      </div>
      <.modal id="periods_management">
        <.form :let={f} for={} as={:periods_creation} phx-submit="periods_creation">
          <.input field={f[:number]} type="number" label="How many periods, you want to create?"/>
          <.input field={f[:start_time]} type="time" label="Opening Time of School"/>
          <.input field={f[:end_time]} type="time" label="Closing Time of School"/>

          <.button class="mt-5">Create Periods</.button>
        </.form>
        <div :if={@periods != []} class="mt-5">
          <%= for period <- @periods do %>
            <div class="border my-3 rounded-lg p-2">
              <div><b>Period Number: </b><%= Map.get(period, "period_number") %></div>
              <div><b>Start Time: </b><%= Map.get(period, "start_time") %></div>
              <div><b>End Time: </b><%= Map.get(period, "end_time") %></div>
            </div>
          <% end %>
        </div>
      </.modal>
    </div>
    """
  end
end
