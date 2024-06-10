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
          <image src="/images/ark_logo.jpeg" />
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
          <div class="border pl-2 py-2 text-center flex items-center justify-center">
            <div class={"h-5 w-5 #{(percentage not in 0..50) && "invisible"}"}>
              <.tick_icon />
            </div>
          </div>
          <div class="border pl-2 py-2 text-center flex items-center justify-center">
            <div class={"h-5 w-5 #{(percentage not in 51..70) && "invisible"}"}>
              <.tick_icon />
            </div>
          </div>
          <div class="border pl-2 py-2 text-center flex items-center justify-center">
            <div class={"h-5 w-5 #{(percentage not in 71..90) && "invisible"}"}>
              <.tick_icon />
            </div>
          </div>
          <div class="border pl-2 py-2 text-center flex items-center justify-center">
            <div class={"h-5 w-5 #{(percentage not in 91..100) && "invisible"}"}>
              <.tick_icon />
            </div>
          </div>
        </div>
      <% end %>
      <div class="mt-5 border-2 border-black flex">
        <div class="font-bold text-lg p-2 grow border-r border-black">
          Remarks
        </div>
        <div class="flex flex-col font-bold grow">
          <div class="border border-black px-2 py-1 font-bold">
            Overall Status:
            <span class="ml-1 font-normal">
              <%= if get_average_percentage(@student.subjects, @term_name) > 32,
                do: "Pass",
                else: "Fail" %>
            </span>
          </div>
          <div class="border border-black px-2 py-1">
            Promoted to next Class?:
            <span class="ml-1 font-normal"><%= promoted?(@student.subjects, @term_name) %></span>
          </div>
          <div class="border border-black px-2 py-1">
            Class In-charge Sign:
          </div>
          <div class="border border-black px-2 py-1 h-20">
            Principal's Sign and Stamp:
          </div>
        </div>
      </div>
    </div>
    """
  end

  def tick_icon(assigns) do
    ~H"""
    <svg id="Layer_1" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 457.57">
      <defs>
        <style>
          .cls-1{fill-rule:evenodd; width: 20px; height: 20px;}
        </style>
      </defs>
      <path
        class="cls-1 h-5 w-5"
        d="M0,220.57c100.43-1.33,121-5.2,191.79,81.5,54.29-90,114.62-167.9,179.92-235.86C436-.72,436.5-.89,512,.24,383.54,143,278.71,295.74,194.87,457.57,150,361.45,87.33,280.53,0,220.57Z"
      />
    </svg>
    """
  end

  def promoted?(subjects, "third_term" = term_name) do
    if get_average_percentage(subjects, term_name) > 32 do
      "Yes"
    else
      "No"
    end
  end

  def promoted?(_subjects, _) do
    "No"
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
