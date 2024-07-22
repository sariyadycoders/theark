# lib/my_app/monthly_insertion.ex
defmodule TheArk.MonthlyAttendanceJob do
  use GenServer

  alias TheArk.Attendances

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    next_month_job()
    {:ok, state}
  end

  def handle_info({:insert_records, current_month_number}, state) do
    Attendances.create_monthly_attendances(current_month_number)
    Attendances.delete_old_attendances(current_month_number)

    # Reschedule for the next month
    next_month_job()

    {:noreply, state}
  end

  defp next_month_job do
    now = Timex.now()
    current_month_number = now.month
    next_month = Timex.shift(now, months: 1)
    next_month_start = Timex.beginning_of_day(Timex.beginning_of_month(next_month))
    seconds_until_start = Timex.diff(next_month_start, now, :second)

    Process.send_after(
      self(),
      {:insert_records, current_month_number},
      seconds_until_start * 1000
    )
  end
end
