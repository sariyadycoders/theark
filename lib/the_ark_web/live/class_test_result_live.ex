defmodule TheArkWeb.ClassTestResultLive do
  use TheArkWeb, :live_view

  alias TheArk.Tests
  alias TheArk.Classes

  @impl true
  def mount(%{"id" => class_id, "test_id" => test_id}, _session, socket) do
    class_test = Tests.get_test!(String.to_integer(test_id))
    class = Classes.get_class_for_tests_page(String.to_integer(class_id))
    results =
      Enum.map(class.students, fn student ->
        test = Tests.get_single_test(class_test.subject, student.id, class_test.date_of_test)

        %{name: student.name, obtained_marks: test.obtained_marks}
      end)

    result_completed? =
      !Enum.any?(results, fn result ->
        is_nil(result.obtained_marks)
      end)

    socket
    |> assign(class_test: class_test)
    |> assign(result_completed?: result_completed?)
    |> assign(class: class)
    |> assign(results: results)
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="max-w-xl mx-auto p-3 border-2 border-black rounded-lg">
        <div class="text-2xl font-bold text-center py-2 border-2">
          Test Result (<%= @class.name %>)
        </div>
        <div class="grid grid-cols-2 border-2 text-xl p-2 items-center">
          <div class="border-r-2">
            <b>Subject:</b> <%= @class_test.subject %>
          </div>
          <div class="pl-2">
            <b>Date:</b> <%= @class_test.date_of_test %>
          </div>
        </div>
        <div class="text-sm text-center my-1">
          <b>T. Marks:</b> <%= @class_test.total_marks %>
        </div>
        <div class="grid grid-cols-4 font-bold">
          <div class="border p-2 text-center">
            Name
          </div>
          <div class="border p-2 text-center">
            O. Marks
          </div>
          <div class="border p-2 text-center">
            %
          </div>
          <div class="border p-2 text-center">
            Status
          </div>
        </div>
        <%= if @result_completed? do %>
          <%= for result <- @results do %>
            <% status = get_status(result.obtained_marks, @class_test.total_marks) %>
            <div class={"grid grid-cols-4 #{if status == "FAIL", do: "bg-gray-100 border border-black"}"}>
              <div class="border p-2 text-center">
                <%= result.name %>
              </div>
              <div class="border p-2 text-center">
                <%= result.obtained_marks %>
              </div>
              <div class="border p-2 text-center">
                <%= get_percentage(result.obtained_marks, @class_test.total_marks) %>
              </div>
              <div class={"border p-2 text-center"}>
                <%= status %>
              </div>
            </div>
          <% end %>
        <% else %>
          <div class="text-sm text-center text-red-600 mt-3">
            Result not submitted completely yet!
          </div>
        <% end %>
      </div>
    """
  end

  defp get_percentage(obtained, total) do
    ((obtained / total) * 100) |> round()
  end

  defp get_status(obtained, total) do
    if get_percentage(obtained, total) > 49 do
      "PASS"
    else
      "FAIL"
    end
  end
end
