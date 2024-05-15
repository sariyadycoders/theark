defmodule TheArk.Shared do
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
end
