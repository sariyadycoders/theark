defmodule TheArkWeb.TeacherResultLive do
  use TheArkWeb, :live_view

  alias TheArk.Classes
  alias TheArk.Teachers
  alias TheArk.Classresults

  @impl true
  def mount(%{"id" => teacher_id}, _session, socket) do
    socket
    |> assign_related_classes(teacher_id)
    |> assign(term_name: nil)
    |> ok()
  end

  @impl true
  def handle_event("choose_term", %{"term_name" => term_name}, socket) do
    socket
    |> assign(term_name: term_name)
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="font-bold text-3xl mb-5">Results for <%= @teacher_name %></h1>
      <div class="flex items-center gap-2 my-5">
        <%= for term_name <- Classes.make_list_of_terms() do %>
          <.button phx-click="choose_term" phx-value-term_name={term_name}>
            See <%= term_name |> String.replace("_", " ") %> Result Sheet
          </.button>
        <% end %>
      </div>

      <div :if={@term_name} class="w-full p-5 border rounded-lg my-5">
        <%= for class <- @classes do %>
          <div class="my-5 border rounded-lg p-5">
            <div class="grid grid-cols-4">
              <div class="border col-span-4 text-center">
                <%= class.name %>
              </div>
              <div class="flex items-center text-center border">
                -
              </div>
              <%= for student <- class.students do %>
                <div class="flex items-center text-center border">
                  <%= student.name %>
                </div>
              <% end %>
            </div>
            <%= for subject <- class.subjects do %>
              <div class="grid grid-cols-4">
                <div class="flex items-center text-center border">
                  <%= subject.name %>
                  <%= get_total_marks_of_term_from_results(subject.classresults, @term_name) %>
                </div>
                <%= for student <- class.students do %>
                  <div class="flex items-center text-center border">
                    <%= get_obtained_marks_of_term_from_subjects(
                      student.subjects,
                      subject.name,
                      @term_name
                    ) %>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>

      <div class="grid grid-cols-6 items-center border-b-4 pb-2 font-bold text-md">
        <div>
          Subject
        </div>
        <div class="col-span-2">
          Students Appeared
        </div>
        <div>
          Total Marks
        </div>
        <div>
          Average O.Marks
        </div>
        <div>
          %
        </div>
      </div>
      <%= for result_name <- Classes.make_list_of_terms() do %>
        <div class="grid grid-cols-6 gap-2">
          <div class="col-span-6 capitalize font-bold my-2">
            <%= String.replace(result_name, "_", " ") %>
          </div>
          <%= for class <- @classes do %>
            <div class="col-span-6 capitalize font-bold my-2">
              <%= class.name %>
            </div>
            <%= for subject <- class.subjects do %>
              <div>
                <a href={"/classes/#{class.id}/results/#{subject.name}/?term=#{result_name}"}>
                  <%= subject.name %>
                </a>
              </div>
              <div class="col-span-2">
                <div>
                  <%= get_number_of_students_appeared(subject.classresults, result_name) %> out of <%= Enum.count(
                    class.students
                  ) %>
                </div>
                <div>
                  <b>Absentee's:</b>
                  <span>
                    <%= for {name, index} <- Enum.with_index(get_names_of_absentees(subject.classresults, result_name)) do %>
                      <%= name %><%= if index ==
                                          Enum.count(
                                            get_names_of_absentees(subject.classresults, result_name)
                                          ) - 1,
                                        do: "",
                                        else: "," %>
                    <% end %>
                  </span>
                </div>
              </div>
              <div>
                <%= get_total_marks_of_term_from_results(subject.classresults, result_name) %>
              </div>
              <div>
                <%= get_obtained_marks_of_term_from_results(subject.classresults, result_name) %>
              </div>
              <div>
                <%= get_percentage_of_marks(subject.classresults, result_name) %>
              </div>
            <% end %>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp assign_related_classes(socket, teacher_id) do
    teacher = Teachers.get_teacher_for_collective_result!(teacher_id)

    teacher_class_ids =
      teacher.subjects
      |> Enum.filter(fn subject ->
        subject.is_class_subject
      end)
      |> Enum.map(fn subject -> subject.class_id end)

    for id <- teacher_class_ids do
      Classresults.prepare_class_results(id)
    end

    teacher = Teachers.get_teacher!(teacher_id)

    classes =
      Enum.map(teacher_class_ids, fn class_id ->
        Classes.get_class_for_teacher_collective_result(class_id, teacher.id)
      end)

    socket
    |> assign(classes: classes)
    |> assign(teacher_name: teacher.name)
  end

  def get_obtained_marks_of_term_from_results(results, term_name) do
    o_marks =
      (Enum.filter(results, fn result -> result.name == term_name end)
       |> Enum.at(0)).obtained_marks

    if o_marks do
      o_marks
    else
      0
    end
  end

  def get_obtained_marks_of_term_from_subjects(subjects, subject_name, term_name) do
    results =
      (Enum.filter(subjects, fn subject ->
         subject.name == subject_name
       end)
       |> Enum.at(0)).results

    o_marks =
      (Enum.filter(results, fn result -> result.name == term_name end)
       |> Enum.at(0)).obtained_marks

    if o_marks do
      o_marks
    else
      0
    end
  end

  def get_total_marks_of_term_from_results(results, term_name) do
    t_marks =
      (Enum.filter(results, fn result -> result.name == term_name end) |> Enum.at(0)).total_marks

    if t_marks do
      t_marks
    else
      0
    end
  end

  def get_percentage_of_marks(results, term_name) do
    if (Enum.filter(results, fn result -> result.name == term_name end)
        |> Enum.at(0)).total_marks &&
         (Enum.filter(results, fn result -> result.name == term_name end)
          |> Enum.at(0)).obtained_marks do
      ((Enum.filter(results, fn result -> result.name == term_name end)
        |> Enum.at(0)).obtained_marks /
         (Enum.filter(results, fn result -> result.name == term_name end)
          |> Enum.at(0)).total_marks * 100)
      |> round()
    else
      0
    end
  end

  def get_number_of_students_appeared(results, term_name) do
    if (Enum.filter(results, fn result -> result.name == term_name end)
        |> Enum.at(0)).students_appeared > 0 and
         !is_nil(
           (Enum.filter(results, fn result -> result.name == term_name end)
            |> Enum.at(0)).students_appeared
         ) do
      (Enum.filter(results, fn result -> result.name == term_name end)
       |> Enum.at(0)).students_appeared
    else
      0
    end
  end

  def get_names_of_absentees(results, term_name) do
    (Enum.filter(results, fn result -> result.name == term_name end)
     |> Enum.at(0)).absent_students
  end
end
