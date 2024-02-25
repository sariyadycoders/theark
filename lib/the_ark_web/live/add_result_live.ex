defmodule TheArkWeb.AddResultLive do
  use TheArkWeb, :live_view

  alias TheArk.{
    Classes,
    Subjects,
    Results,
    Results.Result,
    Students,
    Classresults
  }

  @impl true
  def mount(
        %{"id" => id},
        _session,
        socket
      ) do
    class = Classes.get_class!(id)

    subject_id =
      Enum.map(class.subjects, fn subject ->
        subject.subject_id
      end)
      |> Enum.at(0)

    subject_choosen =
      if subject_id do
        Subjects.get_subject_name_by_subject_id(class.id, subject_id)
      else
        nil
      end

    term = Enum.map(make_term_options(), fn {_key, value} -> value end) |> Enum.at(0)

    total_marks =
      if subject_choosen do
        subject = Subjects.get_subject_by_subject_id(class.id, subject_id)

        (Enum.filter(subject.classresults, fn result ->
           result.name == term
         end)
         |> Enum.at(0)).total_marks
      else
        nil
      end

    socket
    |> assign(class: class)
    |> assign(is_first_term_announced: class.is_first_term_announced)
    |> assign(subject_choosen: subject_choosen)
    |> assign(total_marks: total_marks)
    |> assign(term: term)
    |> assign(subject_id: subject_id)
    |> assign(allowed_result_student_id: 0)
    |> assign(result_changeset: Results.change_result(%Result{}))
    |> assign(total_marks_submitted: false)
    |> ok()
  end

  @impl true
  def handle_event(
        "choose_subject",
        %{
          "class_id" => class_id,
          "choose_subject" => %{"subject_id" => subject_id, "term" => term}
        },
        %{assigns: %{term: term}} = socket
      ) do
    subject_choosen = Subjects.get_subject_name_by_subject_id(class_id, subject_id)
    subject = Subjects.get_subject_by_subject_id(class_id, subject_id)

    total_marks =
      (Enum.filter(subject.classresults, fn result ->
         result.name == term
       end)
       |> Enum.at(0)).total_marks

    socket
    |> assign(subject_choosen: subject_choosen)
    |> assign(subject_id: subject_id)
    |> assign(term: term)
    |> assign(total_marks: total_marks)
    |> assign(total_marks_submitted: false)
    |> noreply()
  end

  @impl true
  def handle_event(
        "insert_total_marks",
        %{
          "class_id" => class_id,
          "insert_total_marks" => %{
            "subject_id" => subject_id,
            "term" => term,
            "total_marks" => total_marks
          }
        },
        socket
      ) do
    subject = Subjects.get_subject_by_subject_id(class_id, subject_id)

    result =
      Enum.filter(subject.classresults, fn result ->
        result.name == term
      end)
      |> Enum.at(0)

    total_marks =
      if total_marks == "" do
        nil
      else
        if String.to_integer(total_marks) > 0, do: String.to_integer(total_marks), else: nil
      end

    if total_marks do
      Classresults.update_classresult(result, %{"total_marks" => total_marks})

      socket
      |> assign(total_marks: total_marks)
      |> assign(total_marks_submitted: true)
      |> put_flash(:info, "Total marks added")
      |> noreply()
    else
      socket
      |> put_flash(:error, "Total marks should be greater than 0")
      |> noreply()
    end
  end

  @impl true
  def handle_event(
        "allowed_result_student_id",
        %{"student_id" => "0"},
        socket
      ) do
    socket
    |> assign(allowed_result_student_id: 0)
    |> noreply()
  end

  @impl true
  def handle_event(
        "allowed_result_student_id",
        %{"student_id" => id},
        %{assigns: %{term: term, subject_choosen: subject_choosen}} = socket
      ) do
    student = Students.get_student!(id)
    result_changeset = result_changeset(student, term, subject_choosen)

    socket
    |> assign(result_changeset: result_changeset)
    |> assign(allowed_result_student_id: String.to_integer(id))
    |> noreply()
  end

  @impl true
  def handle_event(
        "validate_result",
        %{
          "result_id" => result_id,
          "result" => result_params
        },
        socket
      ) do
    result = Results.get_result!(result_id)
    result_changeset = Results.change_result(result, result_params) |> Map.put(:action, :insert)

    socket
    |> assign(result_changeset: result_changeset)
    |> noreply()
  end

  @impl true
  def handle_event(
        "add_result",
        %{
          "result_id" => result_id,
          "result" => result_params
        },
        socket
      ) do
    result = Results.get_result!(result_id)

    case Results.update_result(result, result_params) do
      {:ok, _result} ->
        socket
        |> put_flash(:info, "result added")
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(result_changeset: changeset)
        |> put_flash(:error, "Check obtained marks")
        |> noreply()
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="font-bold text-3xl mb-5">Add Result for Class <%= @class.name %></h1>

      <div :if={Enum.count(make_term_options()) != 0 && !is_nil(@subject_choosen)}>
        <.form
          :let={s}
          for={%{}}
          as={:choose_subject}
          phx-value-class_id={@class.id}
          phx-change="choose_subject"
        >
          <.input
            field={s[:subject_id]}
            type="select"
            label="Choose Subject"
            options={
              Enum.flat_map(@class.subjects, fn subject ->
                [{:"#{subject.name}", subject.subject_id}]
              end)
            }
            value={nil}
          />
          <.input field={s[:term]} type="select" label="Choose Term" options={make_term_options()} />
        </.form>

        <.form
          :let={m}
          for={%{}}
          as={:insert_total_marks}
          phx-value-class_id={@class.id}
          phx-submit="insert_total_marks"
        >
          <.input
            field={m[:total_marks]}
            type="number"
            label="Total Marks"
            placeholder="should be greater than zero"
            value={@total_marks}
          />
          <.input field={m[:subject_id]} type="hidden" label="Choose Subject" value={@subject_id} />
          <.input field={m[:term]} type="hidden" value={@term} />

          <.button class="mt-2">Submit total marks</.button>
        </.form>

        <%= if @total_marks_submitted do %>
          <%= for student <- @class.students do %>
            <div class="relative p-5 border rounded-lg my-3">
              <%= if !(@allowed_result_student_id == student.id) do %>
                <div class="flex items-center justify-between">
                  <div>
                    Are your adding <b><%= @subject_choosen %></b>
                    result for <b><%= student.name %></b>?
                  </div>
                  <.button
                    phx-click="allowed_result_student_id"
                    phx-value-student_id={student.id}
                    class="mt-2"
                  >
                    Yes
                  </.button>
                </div>
              <% else %>
                <div
                  phx-click="allowed_result_student_id"
                  phx-value-student_id="0"
                  class="absolute top-2 right-2 cursor-pointer"
                >
                  &#9746;
                </div>
                <.form
                  :let={f}
                  for={@result_changeset}
                  phx-value-result_id={get_result(student, @term, @subject_choosen)}
                  phx-change="validate_result"
                  phx-submit="add_result"
                >
                  <.input
                    field={f[:obtained_marks]}
                    type="number"
                    label={"Obtained Marks of #{student.name} (out of #{@total_marks})"}
                    placeholder="0 marks means student is absent"
                  />
                  <.input
                    field={f[:total_marks]}
                    type="hidden"
                    label="Total Marks"
                    value={@total_marks}
                  />
                  <.input field={f[:name]} type="hidden" label="Name" value={@term} />

                  <.button class="mt-2">Submit</.button>
                </.form>
              <% end %>
            </div>
          <% end %>
        <% end %>
      </div>

      <div
        :if={Enum.count(make_term_options()) == 0 || is_nil(@subject_choosen)}
        class="p-5 border rounded-lg my-5 text-base-200"
      >
        No term announced yet !
      </div>
    </div>
    """
  end

  def result_changeset(student, term, subject) do
    Results.result_changeset_for_result_edition(student, term, subject)
  end

  def get_result(student, term, subject) do
    Results.get_result_of_student(student, term, subject).id
  end

  def make_term_options() do
    class = Classes.get_any_one_class()

    cond do
      class.is_first_term_announced and class.is_second_term_announced and
          class.is_third_term_announced ->
        ["First Term": "first_term", "Second Term": "second_term", "Third Term": "third_term"]

      class.is_first_term_announced and class.is_second_term_announced ->
        ["First Term": "first_term", "Second Term": "second_term"]

      class.is_first_term_announced ->
        ["First Term": "first_term"]

      true ->
        []
    end
  end
end
