defmodule TheArkWeb.StudentPerformanceLive do
  use TheArkWeb, :live_view

  alias TheArk.{
    Students
  }

  @impl true
  def mount(%{"id" => student_id}, _session, socket) do
    student = Students.get_student!(student_id)

    socket
    |> assign(student: student)
    |> assign_terms_data()
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
        Regular Terms Result
      </div>
      <canvas id="chart-canvas" data-chart-data={Jason.encode!(@terms_data)} phx-hook="LineChartHook">
      </canvas>
    </div>
    """
  end

  defp assign_terms_data(%{assigns: %{student: student}} = socket) do
    data = prepare_data(student.results)
    labels = get_labels(data)
    values = get_values(data)

    socket
    |> assign(terms_data: %{labels: labels, values: values, heading: "results"})
  end

  defp prepare_data(results) do
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

  defp get_labels(data) do
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

  def get_values(data) do
    [0] ++
      Enum.flat_map(data, fn {_year, results} ->
        Enum.map(results, fn {_term, result} ->
          result
        end)
      end)
  end
end
