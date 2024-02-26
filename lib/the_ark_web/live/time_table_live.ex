defmodule TheArkWeb.TimeTableLive do
  use TheArkWeb, :live_view

  alias TheArk.Classes

  @impl true
  def mount(_, _, socket) do
    socket
    |> assign(classes: Classes.list_classes())
    |> assign(allow_periods_creation: false)
    |> assign(periods: [])
    |> ok
  end
  @impl true
  def handle_event("allow_periods_creation", _unsigned_params, socket) do
    socket
    |> assign(allow_periods_creation: true)
    |> noreply()
  end

  @impl true
  def handle_event("periods_creation",
    %{"periods_creation" => %{"number" => number, "start_time" => start_time, "end_time" => end_time}},
    socket) do

    periods = []

    {:ok, start_time} = Time.from_iso8601(start_time <> ":00")
    {:ok, end_time} = Time.from_iso8601(end_time <> ":00")

    time_difference = Time.diff(end_time, start_time)
    time_of_slot = (time_difference / String.to_integer(number)) |> round()

    periods =
      for number <- 1..String.to_integer(number) do
        periods ++ [%{"period_number" => number, "start_time" => Time.add(start_time, (time_of_slot)*(number-1)), "end_time" => Time.add(Time.add(start_time, (time_of_slot)*(number-1)), time_of_slot), "is_custom_set" => false}]
      end

    socket
    |> assign(periods: Enum.flat_map(periods, fn x -> x end))
    |> assign(time_difference: time_difference)
    |> assign(start_time: start_time)
    |> noreply()
  end


  @impl true
  def handle_event("edit_period_duration",
    %{"period_duration" => %{"duration" => duration}, "period_number" => period_number},
    %{assigns: %{periods: periods, time_difference: time_difference, start_time: start_time}} = socket) do

    periods =
      Enum.map(periods, fn period ->
        if Map.get(period, "period_number") == String.to_integer(period_number) do
          Map.put(period, "is_custom_set", true)
          |> Map.put("duration", String.to_integer(duration))
        else
          period
        end
      end)

    duration_to_be_subtracted =
      Enum.reduce(periods, 0, fn period, acc ->
        if Map.get(period, "is_custom_set") do
          acc + (Map.get(period, "duration")*60)
        else
          acc
        end
      end)

    non_custom_periods_count =
      Enum.filter(periods, fn period ->
        !Map.get(period, "is_custom_set")
      end)
      |> Enum.count()

    remaining_time =
      time_difference - duration_to_be_subtracted

    new_slot_time =
      (remaining_time / non_custom_periods_count) |> round()

    accumulator =
      %{"start_time" => start_time}

    periods =
      Enum.scan(periods, accumulator, fn period, acc ->
        if Map.get(period, "period_number") == 1 do
          period = Map.put(period, "start_time", Map.get(acc, "start_time"))
          if Map.get(period, "period_number") == String.to_integer(period_number) do
            Map.put(period, "end_time", Time.add(Map.get(acc, "start_time"), String.to_integer(duration)*60))
          else
            if Map.get(period, "is_custom_set") do
              Map.put(period, "end_time", Time.add(Map.get(acc, "start_time"), Map.get(period, "duration")*60))
            else
              Map.put(period, "end_time", Time.add(Map.get(acc, "start_time"), new_slot_time))
            end
          end
        else
          if Map.get(period, "is_custom_set") do
            Map.put(period, "start_time", Map.get(acc, "end_time"))
            |> Map.put("end_time", Time.add(Map.get(acc, "end_time"), Map.get(period, "duration")*60))
          else
            Map.put(period, "start_time", Map.get(acc, "end_time"))
            |> Map.put("end_time", Time.add(Map.get(acc, "end_time"), new_slot_time))
          end
        end
      end)

    socket
    |> assign(periods: periods)
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between">
        <h1 class="font-bold text-3xl my-5">Time Table</h1>
        <.button phx-click="allow_periods_creation">Create or Edit Periods</.button>
      </div>
      <div :if={@allow_periods_creation} class="my-5 border rounded-lg p-5">
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

              <.button
                icon="hero-pencil"
                phx-click={show_modal("edit_period_#{Map.get(period, "period_number")}")}
              />

              <.modal id={"edit_period_#{Map.get(period, "period_number")}"}>
                <.form :let={f} for={} as={:period_duration} phx-value-period_number={Map.get(period, "period_number")} phx-submit="edit_period_duration">
                  <.input field={f[:duration]} type="number" min="10" label="Duration"/>

                  <.button class="mt-5">Add Duration</.button>
                </.form>
              </.modal>
            </div>
          <% end %>
        </div>
      </div>
      <div class="border rounded-lg my-5 p-5">
        time table
      </div>
    </div>
    """
  end
end
