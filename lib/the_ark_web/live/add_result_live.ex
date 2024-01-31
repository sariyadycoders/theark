defmodule TheArkWeb.AddResultLive do
  use TheArkWeb, :live_view

  alias TheArk.{
    Classes,
    Subjects,
    Results
  }

  @term_options ["First Term": "first_term", "Second Term": "second_term", "Third Term": "third_term"]

  @impl true
  def mount(%{"class_id" => id}, _session, socket) do
    class = Classes.get_class!(id)

    socket
    |> assign(class: class)
    |> assign(subject_choosen: false)
    |> assign(total_marks: nil)
    |> assign(term: nil)
    |> assign(term_options: @term_options)
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
            <div class="mt-5">
              Add <%= @subject_choosen %> result for <%= student.name%>. Out of <%= @total_marks %>
            </div>
            <.form :let={f} for={result_changeset(student, @term, @subject_choosen)} phx-submit="add_result">
              <.input field={f[:obtained_marks]} type="number" label="Obtained Marks" value={0}/>
              <.input field={f[:total_marks]} type="hidden" label="Total Marks" value={@total_marks}/>
              <.input field={f[:name]} type="text" label="Name"/>


            </.form>





          <% end %>
        <% end %>





      </div>

    """
  end

  def result_changeset(student, term, subject) do
    Results.result_changeset_for_result_edition(student, term, subject)
  end
end
