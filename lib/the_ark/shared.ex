defmodule TheArk.Shared do
  alias TheArk.Offdays

  def first_date_of_month(selected_month) do
    current_month_number = Date.utc_today().month
    selected_month_number = Timex.month_to_num(selected_month)

    year =
      if current_month_number in [1, 2] and selected_month_number in [11, 12] do
        Date.utc_today().year - 1
      else
        Date.utc_today().year
      end

    {:ok, first_date_of_month} = Date.new(year, selected_month_number, 1)

    first_date_of_month
  end

  def list_of_dates(month) do
    first_date_of_month = first_date_of_month(month)

    days_in_month = Timex.days_in_month(first_date_of_month)

    list_of_dates =
      Enum.map(1..days_in_month, fn num ->
        Date.add(first_date_of_month, num - 1)
      end)

    list_of_dates
  end

  def total_days_in_month(month_number) do
    Timex.month_name(month_number)
    |> first_date_of_month()
    |> Timex.days_in_month()
  end

  def next_month_number(current_number) do
    if current_number == 12, do: 1, else: current_number + 1
  end

  def prev_month_number(current_number, "dynamic") do
    if current_number > 0 do
      prev_month_number(current_number)
    else
      11 - current_number * -1
    end
  end

  def prev_month_number(current_number) do
    if current_number == 1, do: 12, else: current_number - 1
  end

  def working_days_in_month(month_number, year) do
    off_days = Offdays.get_offday_by_month_number(month_number, year, "students")

    off_days = if off_days, do: off_days.days, else: []

    total_days_in_month(month_number) -
      Enum.count(off_days)
  end

  def determine_attendance_completion(attendance) do
    days_in_month = total_days_in_month(attendance.month_number)

    off_days =
      Offdays.get_offday_by_month_number(attendance.month_number, attendance.year, "students")

    off_days = if off_days, do: off_days.days, else: []

    total_marked_days =
      attendance.number_of_half_leaves + attendance.number_of_leaves +
        attendance.number_of_absents + attendance.number_of_presents

    days_should_be_marked = days_in_month - Enum.count(off_days)

    if total_marked_days < days_should_be_marked do
      "no"
    else
      "yes"
    end
  end

  def last_eleven_months() do
    Enum.map(1..11, fn number ->
      current_month = Date.utc_today().month

      prev_month_number(current_month - (number - 1), "dynamic")
    end)
  end
end
