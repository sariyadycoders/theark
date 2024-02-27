defmodule TheArkWeb.TimeTableLive do
  alias TheArk.Periods.Period
  use TheArkWeb, :live_view

  alias TheArk.Classes
  alias TheArk.Periods
  alias TheArk.Periods.Period
  alias TheArk.Subjects
  alias TheArk.Teachers

  @impl true
  def mount(_, _, socket) do
    classes = Classes.list_classes()
    class = List.first(classes)

    socket
    |> assign(classes: classes)
    |> assign(class: class)
    |> assign(allow_periods_creation: false)
    |> assign(periods: [])
    |> assign(periods_created: nil)
    |> assign(subject_options: [])
    |> assign(teacher_options: Teachers.get_teacher_options())
    |> assign(period_changeset: Periods.change_period(%Period{}))
    |> assign(allow_period_population: 0)
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
    |> assign(periods_created: true)
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
  def handle_event("insert_periods",
    _unsigned_params,
    %{assigns: %{periods: periods}} = socket) do

    {_, is_nil} = Periods.delete_all_periods()

    if !is_nil do
      for id <- Classes.get_all_class_ids() do
        for period <- periods do
          Periods.create_period(Map.put(period, "class_id", id))
        end
      end
    end

    classes = Classes.list_classes()
    class = List.first(classes)

    socket
    |> assign(classes: classes)
    |> assign(class: class)
    |> assign(periods_created: nil)
    |> assign(allow_periods_creation: false)
    |> put_flash(:info, "New periods created successfully!")
    |> noreply()
  end

  @impl true
  def handle_event("edit_old_periods",
    _unsigned_params,
    %{assigns: %{periods: periods, class: class}} = socket) do

    new_period_numbers = Enum.map(periods, fn period -> Map.get(period, "period_number") end)
    old_period_numbers = Enum.map(class.periods, fn period -> period.period_number end)

    period_numbers_to_be_deleted = Enum.filter(old_period_numbers, fn number -> number not in new_period_numbers end)
    period_numbers_to_be_inserted = Enum.filter(new_period_numbers, fn number -> number not in old_period_numbers end)
    periods_to_be_inserted = Enum.filter(periods, fn period -> Map.get(period, "period_number") in period_numbers_to_be_inserted end)
    period_numbers_to_be_updated = Enum.filter(new_period_numbers, fn number -> number in old_period_numbers end)
    periods_to_be_updated = Enum.filter(periods, fn period -> Map.get(period, "period_number") in period_numbers_to_be_updated end)


    Periods.delete_periods_with_period_numbers(period_numbers_to_be_deleted)

    for period <- periods_to_be_inserted do
      for id <- Classes.get_all_class_ids() do
        Periods.create_period(Map.put(period, "class_id", id))
      end
    end

    for period <- periods_to_be_updated do
      old_periods = Periods.get_periods_by_number(Map.get(period, "period_number"))
      for old_period <- old_periods do
        Periods.update_period(old_period, period)
      end
    end

    classes = Classes.list_classes()
    class = List.first(classes)

    socket
    |> assign(classes: classes)
    |> assign(class: class)
    |> assign(periods_created: nil)
    |> assign(allow_periods_creation: false)
    |> put_flash(:info, "Periods updated successfully!")
    |> noreply()
  end

  @impl true
  def handle_event("allow_period_population", %{"period_id" => period_id, "class_id" => class_id}, socket) do
    subject_options = Subjects.get_subject_options_for_select(String.to_integer(class_id))
    period = Periods.get_period!(period_id)
    period_changeset = Periods.change_period(period)

    socket
    |> assign(subject_options: subject_options)
    |> assign(allow_period_population: String.to_integer(period_id))
    |> assign(period_changeset: period_changeset)
    |> noreply()
  end

  @impl true
  def handle_event("period_population",
    %{"period_id" => period_id, "period" => params}, socket) do

    period = Periods.get_period!(period_id)

    case Periods.update_period(period, params) do
      {:ok, _period} ->
        socket
        |> put_flash(:info, "Period updated successfully!")
        |> assign(period_changeset: Periods.change_period(%Period{}))
        |> assign(classes: Classes.list_classes())
        |> noreply()
      {:error, period_changeset} ->
        socket
        |> assign(period_changeset: period_changeset)
        |> noreply()
    end
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

        <div :if={@periods_created} class="flex gap-2">
          <.button phx-click="insert_periods" class="mt-5">Generate New Periods</.button>
          <.button phx-click="edit_old_periods" class="mt-5">Update Old Periods</.button>
        </div>
      </div>
      <div class="border rounded-lg my-5 p-5">
        <div class="grid grid-cols-10 items-center font-bold">
          <div class="font-bold text-center">
            Class
          </div>
          <%= for period <- @class.periods do %>
            <div class="border p-1 text-center">
              <div class=""><%= period.period_number %></div>
              <div class="text-sm "><%= make_time_string(period.start_time) %> to <%= make_time_string(period.end_time) %></div>
            </div>
          <% end %>
        </div>
        <%= for class <- @classes do %>
          <div class="grid grid-cols-10 items-center">
            <div class="text-center">
              <div><%= class.name %></div>
              <div class="text-sm"><%= class.incharge %></div>
            </div>
            <%= for period <- class.periods do %>
              <div phx-click={JS.push("allow_period_population") |> show_modal("edit_period_#{period.id}")} phx-value-class_id={class.id} phx-value-period_id={period.id} class="border p-1 text-center cursor-pointer">
                <div class=""><%= if period.subject, do: period.subject, else: "N/A" %></div>
                <div class=""><%= if period.teacher, do: period.teacher.name, else: "N/A" %></div>
              </div>
              <.modal id={"edit_period_#{period.id}"}>
                <%= if @allow_period_population == period.id do %>
                  <.form :let={f} for={@period_changeset} phx-value-period_id={period.id} phx-submit="period_population">
                    <.input field={f[:subject]} type="select" options={@subject_options} label="Subject"/>
                    <.input field={f[:teacher_id]} type="select" options={@teacher_options} label="Teacher"/>

                    <.button class="mt-5">Populate</.button>
                  </.form>
                <% end %>
              </.modal>
            <% end %>
          </div>


        <% end %>
      </div>
    </div>
    """
  end

  def make_time_string(time) do
    Time.to_string(time)
    |> String.slice(0..4)
  end
end
