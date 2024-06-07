defmodule TheArkWeb.StudentTermResultLive do
  use TheArkWeb, :live_view

  import TheArkWeb.ClassResultLive,
    only: [
      get_total_marks_of_term_from_results: 2,
      get_obtained_marks_of_term_from_results: 2,
      get_percentage_of_marks: 2
    ]

  alias TheArk.Students

  @impl true
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
    <div class="p-5 border-4 rounded-lg my-5 border-black">
      <div class="flex justify-between my-5">
        <div class="border w-28 h-28">
          Logo
        </div>
        <div class="flex flex-col">
          <div class="font-bold">
            <p class="text-4xl">THE ARK MONTESSORI SCHOOL SYSTEM</p>
            <p class="text-center">
              Mohalla Islam wala, Near Madni Road, Khiali, Gujranwala. Contact: 0321-7401330
            </p>
          </div>
          <div class="font-bold mt-5">
            <p class="text-5xl text-center">Report Card</p>
            <p class="text-center mt-2 capitalize">
              <%= String.split(@term_name, "_") |> Enum.join(" ") %> Exams, 2024
            </p>
          </div>
        </div>
        <div class="border-2 border-black w-40 h-40 flex items-center justify-center">
          <div class="font-bold text-8xl">
            <%= get_grade(@student.subjects, @term_name) %>
          </div>
        </div>
      </div>
      <div class="my-5 grid grid-cols-3">
        <div class="border-2 p-2">
          <b class="mr-3">Student's Name:</b><%= @student.name %>
        </div>
        <div class="border-2 p-2">
          <b class="mr-3">Father's Name:</b><%= @student.father_name %>
        </div>
        <div class="border-2 p-2">
          <b class="mr-3">Class:</b><%= @student.class.name %>
        </div>
      </div>
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
      <%= for subject <- @student.subjects, !String.ends_with?(subject.name, "_t") do %>
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
      <div class="mt-1 text-lg grid grid-cols-5 font-bold">
        <div class="border-2 flex flex-col py-2 px-2">
          <div class="col-span-2">Result</div>
        </div>
        <div class="border-2 flex flex-col py-2">
          <div class="col-span-2 text-center">
            <%= get_net_total_marks(@student.subjects, @term_name) %>
          </div>
        </div>
        <div class="border-2 flex flex-col py-2">
          <div class="col-span-2 text-center">
            <%= get_net_obtained_marks(@student.subjects, @term_name) %>
          </div>
        </div>
        <div class="border-2 flex flex-col py-2">
          <div class="col-span-2 text-center">
            <%= get_average_percentage(@student.subjects, @term_name) |> round() %>
          </div>
        </div>
        <div class="border-2 flex flex-col py-2">
          <div class="col-span-2 text-center">
            <%= if get_average_percentage(@student.subjects, @term_name) > 32,
              do: "Pass",
              else: "Fail" %>
          </div>
        </div>
      </div>

      <div class="mt-5 mb-2 font-bold text-xl text-center capitalize">Perosonality Traits</div>
      <div class="grid grid-cols-5 items-center font-bold">
        <div class="border flex flex-col py-2">
          <div class="col-span-2 text-center">Trait</div>
        </div>
        <div class="border flex flex-col py-2">
          <div class="col-span-2 text-center">Weak</div>
        </div>
        <div class="border flex flex-col py-2">
          <div class="col-span-2 text-center">Good</div>
        </div>
        <div class="border flex flex-col py-2">
          <div class="col-span-2 text-center">Better</div>
        </div>
        <div class="border flex flex-col py-2">
          <div class="col-span-2 text-center">Best</div>
        </div>
      </div>
      <%= for subject <- @student.subjects, String.ends_with?(subject.name, "_t") do %>
        <% percentage = get_percentage_of_marks(subject.results, @term_name) %>
        <div class="grid grid-cols-5 items-center">
          <div class="border pl-2 py-1">
            <%= subject.name |> String.slice(0..-3) %>
          </div>
          <div class="border pl-2 py-1 text-center">
            <.icon
              name="hero-check-solid"
              class={"h-5 w-5 #{(percentage not in 0..50) && "text-white"}"}
            />
          </div>
          <div class="border pl-2 py-1 text-center">
            <.icon
              name="hero-check-solid"
              class={"h-5 w-5 #{(percentage not in 51..70) && "text-white"}"}
            />
          </div>
          <div class="border pl-2 py-1 text-center">
            <.icon
              name="hero-check-solid"
              class={"h-5 w-5 #{(percentage not in 71..90) && "text-white"}"}
            />
          </div>
          <div class="border pl-2 py-1 text-center">
            <.icon
              name="hero-check-solid"
              class={"h-5 w-5 #{(percentage not in 91..100) && "text-white"}"}
            />
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def get_net_total_marks(subjects, term_name) do
    Enum.reject(subjects, fn subject ->
      subject.name
      |> String.ends_with?("_t")
    end)
    |> Enum.map(fn subject ->
      get_total_marks_of_term_from_results(subject.results, term_name)
    end)
    |> Enum.sum()
  end

  def get_net_obtained_marks(subjects, term_name) do
    Enum.reject(subjects, fn subject ->
      subject.name
      |> String.ends_with?("_t")
    end)
    |> Enum.map(fn subject ->
      get_obtained_marks_of_term_from_results(subject.results, term_name)
    end)
    |> Enum.sum()
  end

  def get_average_percentage(subjects, term_name) do
    (Enum.reject(subjects, fn subject ->
       subject.name
       |> String.ends_with?("_t")
     end)
     |> Enum.map(fn subject ->
       get_percentage_of_marks(subject.results, term_name)
     end)
     |> Enum.sum()) / Enum.count(subjects)
  end

  def get_grade(subjects, term_name) do
    percentage = get_average_percentage(subjects, term_name) |> round()

    cond do
      percentage in 80..100 -> "A+"
      percentage in 70..79 -> "A"
      percentage in 60..69 -> "B"
      percentage in 50..59 -> "C"
      percentage in 40..49 -> "D"
      percentage in 33..39 -> "E"
      true -> "F"
    end
  end
end
