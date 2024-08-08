defmodule TheArkWeb.StudentPerformanceLive do
  use TheArkWeb, :live_view

  alias TheArk.{
    Students,
    Attendances
  }

  alias TheArkWeb.SharedLive

  @impl true
  def mount(%{"id" => student_id}, _session, socket) do
    student = Students.get_student_for_performance_page(student_id)
    student_id = String.to_integer(student_id)

    attendances =
      Attendances.get_student_monthly_attendances_to_show(student_id)
      |> Enum.filter(fn attendance ->
        attendance.month_number in last_eleven_months()
      end)
      |> Enum.sort_by(& &1.inserted_at, {:desc, Date})

    socket
    |> assign(student: student)
    |> assign(attendances: attendances)
    |> assign_terms_data()
    |> assign_tests_data()
    |> ok
  end

  @impl true
  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="font-bold text-3xl">Performance Statistics</h1>
      <div class="flex gap-5">
        <div><b>Student Name: </b> <%= @student.name %></div>
        <div><b>Father Name: </b> <%= @student.father_name %></div>
        <div><b>Class: </b> <%= @student.class.name %></div>
      </div>
      <div class="mt-5 text-xl font-bold">
        Attendance Stats
      </div>
      <div class="border-2 border-black p-5 rounded-lg">
        <SharedLive.student_attendance_heading assigns={assigns} />
        <SharedLive.student_attendance_table attendances={@attendances} />
      </div>
      <div class="mt-5 text-xl font-bold">
        Regular Terms Result
      </div>
      <canvas id="chart-canvas" data-chart-data={Jason.encode!(@terms_data)} phx-hook="LineChartHook">
      </canvas>

      <div class="mt-10 text-xl font-bold">
        Class Tests Result
      </div>
      <canvas
        id="chart-canvas-2"
        data-chart-data={Jason.encode!(@tests_data)}
        phx-hook="LineChartHook"
      >
      </canvas>
    </div>
    """
  end

  defp assign_terms_data(%{assigns: %{student: student}} = socket) do
    data = prepare_data(student.results, "terms")
    labels = get_labels(data, "terms")
    values = get_values(data, "terms")

    socket
    |> assign(terms_data: %{labels: labels, values: values, heading: "results"})
  end

  defp assign_tests_data(%{assigns: %{student: student}} = socket) do
    data = prepare_data(student.tests, "tests")
    labels = get_labels(data, "tests")
    values = get_values(data, "tests")

    socket
    |> assign(tests_data: %{labels: labels, values: values, heading: "results"})
  end

  defp prepare_data(results, "terms") do
    Enum.reject(results, &String.ends_with?(&1.subject_of_result, "_t"))
    |> Enum.group_by(fn data -> data.year end, fn data ->
      data
    end)
    |> Enum.map(fn {key, value} ->
      value =
        Enum.group_by(value, & &1.name, & &1)
        |> Enum.map(fn {inner_key, inner_values} ->
          total_marks =
            Enum.map(inner_values, fn v ->
              v.total_marks
            end)
            |> Enum.sum()

          obtained_marks =
            Enum.map(inner_values, fn v ->
              v.obtained_marks
            end)
            |> Enum.sum()

          inner_value =
            (obtained_marks / total_marks * 100)
            |> round()

          {inner_key, inner_value}
        end)
        |> Enum.into(%{})

      {key, value}
    end)
    |> Enum.into(%{})
    |> Enum.sort(:asc)
  end

  defp prepare_data(tests, "tests") do
    Enum.group_by(tests, & &1.date_of_test, & &1)
    |> Enum.map(fn {key, values} ->
      active_values =
        Enum.reject(values, fn v ->
          is_nil(v.obtained_marks)
        end)

      total_percentage =
        active_values
        |> Enum.map(fn v ->
          total = v.total_marks
          obtained = v.obtained_marks

          (obtained / total * 100) |> round()
        end)
        |> Enum.sum()

      net_percentage =
        if Enum.any?(active_values),
          do: (total_percentage / Enum.count(active_values)) |> round(),
          else: nil

      if !net_percentage, do: nil, else: {key, net_percentage}
    end)
    |> Enum.reject(&is_nil(&1))
    |> Enum.sort(fn {date1, _}, {date2, _} -> Date.compare(date1, date2) == :lt end)
  end

  defp get_labels(data, "terms") do
    ["start"] ++
      Enum.flat_map(data, fn {year, results} ->
        Enum.map(results, fn {term, _result} ->
          name =
            case term do
              "first_term" -> "FT"
              "second_term" -> "ST"
              "third_term" -> "TT"
            end

          "#{name}-#{Integer.to_string(year) |> String.slice(2, 2)}"
        end)
      end)
  end

  defp get_labels(data, "tests") do
    ["start"] ++
      Enum.map(data, fn {date, _result} ->
        month = Timex.month_shortname(date.month)
        year = date.year |> Integer.to_string() |> String.slice(2, 2)

        "#{month} #{date.day}, #{year}"
      end)
  end

  def get_values(data, "terms") do
    [0] ++
      Enum.flat_map(data, fn {_year, results} ->
        Enum.map(results, fn {_term, result} ->
          result
        end)
      end)
  end

  def get_values(data, "tests") do
    [0] ++
      Enum.map(data, fn {_date, result} ->
        result
      end)
  end
end
