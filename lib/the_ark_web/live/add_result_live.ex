defmodule TheArkWeb.AddResultLive do
  use TheArkWeb, :live_view

  alias TheArk.{
    Classes,
    Subjects,
    Results,
    Results.Result,
    Students
  }
  alias TheArkWeb.ClassLive

  @term_options ["First Term": "first_term", "Second Term": "second_term", "Third Term": "third_term"]

  @impl true
  def mount(
    %{"class_id" => id},
    _session,
    socket) do

    class = Classes.get_class!(id)

    socket
    |> assign(class: class)
    |> assign(is_first_term_announced: class.is_first_term_announced)
    |> assign(subject_choosen: false)
    |> assign(total_marks: nil)
    |> assign(term: nil)
    |> assign(term_options: @term_options)
    |> assign(allowed_result_student_id: 0)
    |> assign(result_changeset: Results.change_result(%Result{}))
    |> ok()
  end

  @impl true
  def handle_event("choose_subject",
    %{"class_id" => class_id, "choose_subject" => %{"subject_id" => subject_id, "term" => term, "total_marks" => total_marks}},
    socket) do

    subject_choosen = Subjects.get_subject_by_subject_id(class_id, subject_id)
    total_marks=
      if total_marks == "" do
        nil
      else
        if String.to_integer(total_marks) > 0, do: String.to_integer(total_marks), else: nil
      end

    socket
    |> assign(subject_choosen: subject_choosen)
    |> assign(term: term)
    |> assign(total_marks: total_marks)
    |> noreply()
  end

  @impl true
  def handle_event("allowed_result_student_id",
    %{"student_id" => "0"},
    socket) do

    socket
    |> assign(allowed_result_student_id: 0)
    |> noreply()
  end

  @impl true
  def handle_event("allowed_result_student_id",
    %{"student_id" => id},
    %{assigns: %{term: term, subject_choosen: subject_choosen}} = socket) do
    student = Students.get_student!(id)
    result_changeset = result_changeset(student, term, subject_choosen)

    socket
    |> assign(result_changeset: result_changeset)
    |> assign(allowed_result_student_id: String.to_integer(id))
    |> noreply()
  end

  @impl true
  def handle_event("validate_result",
    %{
      "result_id" => result_id,
      "result" => result_params
    },
    socket) do

    result = Results.get_result!(result_id)
    result_changeset = Results.change_result(result, result_params) |> Map.put(:action, :insert)

    socket
    |> assign(result_changeset: result_changeset)
    |> noreply()
  end

  @impl true
  def handle_event("add_result",
    %{
      "result_id" => result_id,
      "result" => result_params
    },
    socket) do

    result = Results.get_result!(result_id)

    case Results.update_result(result, result_params) do
      {:ok, _result} ->
        socket
        |> assign(result_changeset: Results.change_result(%Result{}))
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
        <.form :let={s} for={%{}} as={:choose_subject} phx-value-class_id={@class.id} phx-change="choose_subject">
          <.input field={s[:subject_id]} type="select" label="Choose Subject" options={Enum.flat_map(@class.subjects, fn subject -> ["#{subject.name}": subject.subject_id] end)} value={nil} />
          <.input field={s[:term]} type="select" label="Choose Term" options={@term_options} />
          <.input field={s[:total_marks]} type="number" label="Total Marks" value={0}/>

        </.form>
        <%= if @subject_choosen && @term && @total_marks do %>
          <%= for student <- @class.students do %>
            <div class="relative p-5 border rounded-lg my-3">
              <%= if !(@allowed_result_student_id == student.id) do %>
                <div class="flex items-center justify-between">
                  <div>Are your adding <b><%= @subject_choosen %></b> result for <b><%= student.name%></b>?</div>
                  <.button phx-click="allowed_result_student_id" phx-value-student_id={student.id} class="mt-2">Yes
                  </.button>
                </div>
              <% else %>
                <div phx-click="allowed_result_student_id" phx-value-student_id="0" class="absolute top-2 right-2 cursor-pointer">
                  &#9746;
                </div>
                <.form :let={f} for={@result_changeset} phx-value-result_id={get_result(student, @term, @subject_choosen)} phx-change="validate_result" phx-submit="add_result">
                  <.input field={f[:obtained_marks]} type="number" label={"Obtained Marks of #{student.name} (out of #{@total_marks})"}/>
                  <.input field={f[:total_marks]} type="hidden" label="Total Marks" value={@total_marks}/>
                  <.input field={f[:name]} type="hidden" label="Name" value={@term}/>

                  <.button class="mt-2">Submit</.button>
                </.form>
              <% end %>
            </div>
          <% end %>
        <% end %>





      </div>

    """
  end

  def result_changeset(student, term, subject) do
    Results.result_changeset_for_result_edition(student, term, subject)
  end

  def get_result(student, term, subject) do
    (Results.get_result_of_student(student, term, subject)).id
  end
end
