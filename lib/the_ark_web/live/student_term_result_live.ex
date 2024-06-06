defmodule TheArkWeb.StudentTermResultLive do
  use TheArkWeb, :live_view

  import TheArkWeb.ClassResultLive,
    only: [
      get_total_marks_of_term_from_results: 2,
      get_obtained_marks_of_term_from_results: 2,
      get_percentage_of_marks: 2
    ]

  alias TheArk.Students

  def mount(%{"id" => student_id, "term" => term}, _session, socket) do
    student = Students.get_student!(String.to_integer(student_id))

    socket
    |> assign(student: student)
    |> assign(term_name: term)
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        <div :if={@term_name} class="w-full p-5 border rounded-lg my-5">
          <div class="grid grid-cols-5 items-center font-bold">
            <div class="border flex flex-col py-2">
              <div class="col-span-2 text-center">Subject Name</div>
            </div>
            <div class="border flex flex-col py-2">
              <div class="col-span-2 text-center">Total Marks</div>
            </div>
            <div class="border flex flex-col py-2">
              <div class="col-span-2 text-center">Obtained Marks</div>
            </div>
            <div class="border flex flex-col py-2">
              <div class="col-span-2 text-center">Percentage</div>
            </div>
            <div class="border flex flex-col py-2">
              <div class="col-span-2 text-center">Status</div>
            </div>
          </div>
          <%= for subject <- @student.subjects do %>
            <div class="grid grid-cols-5 items-center">
              <div class="border pl-2 py-1">
                <%= subject.name %>
              </div>
              <div class="border pl-2 py-1 text-center">
                <%= get_total_marks_of_term_from_results(subject.results, @term_name) %>
              </div>
              <div class="border pl-2 py-1 text-center">
                <%= get_obtained_marks_of_term_from_results(subject.results, @term_name) %>
              </div>
              <div class="border pl-2 py-1 text-center">
                <%= get_percentage_of_marks(subject.results, @term_name) %>
              </div>
              <div class="border pl-2 py-1 text-center">
                <%= if get_percentage_of_marks(subject.results, @term_name) > 32,
                  do: "Pass",
                  else: "Fail" %>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    """
  end
end
