defmodule TheArkWeb.AddResultLive do
  use TheArkWeb, :live_view

  alias TheArk.{
    Classes,
    Subjects,
    Results,
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

        result =
          Enum.filter(subject.classresults, fn result ->
            result.name == term
          end)
          |> Enum.at(0)

        if result, do: result.total_marks, else: nil
      else
        nil
      end

    socket
    |> assign(class: class)
    |> assign(subject_choosen: subject_choosen)
    |> assign(total_marks: total_marks)
    |> assign(term: term)
    |> assign(subject_id: subject_id)
    |> assign(total_marks_submitted: false)
    |> assign(result_changesets: [])
    |> ok()
  end

  @impl true
  def handle_event(
        "choose_configurations",
        %{
          "class_id" => class_id,
          "choose_configurations" => %{
            "subject_id" => subject_id,
            "term" => term,
            "total_marks" => _total_marks
          }
        },
        socket
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
          "choose_configurations" => %{
            "subject_id" => subject_id,
            "term" => term,
            "total_marks" => total_marks
          }
        },
        %{assigns: %{class: class, subject_choosen: subject_choosen}} = socket
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

      result_changesets =
        Enum.map(class.students, fn student ->
          %{
            name: student.name,
            changeset: result_changeset(student, term, subject_choosen),
            result_id: get_result_id(student, term, subject_choosen),
            is_submitted: false
          }
        end)

      socket
      |> assign(total_marks: total_marks)
      |> assign(total_marks_submitted: true)
      |> assign(result_changesets: result_changesets)
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
        "validate_result",
        %{
          "result_id" => result_id,
          "result" => result_params
        },
        %{assigns: %{result_changesets: result_changesets}} = socket
      ) do
    result = Results.get_result!(result_id)
    result_changeset = Results.change_result(result, result_params) |> Map.put(:action, :insert)

    result_changesets =
      Enum.map(result_changesets, fn change ->
        if change.result_id == String.to_integer(result_id) do
          Map.put(change, :changeset, result_changeset)
        else
          change
        end
      end)

    socket
    |> assign(result_changesets: result_changesets)
    |> noreply()
  end

  @impl true
  def handle_event(
        "add_result",
        %{
          "result_id" => result_id,
          "result" => result_params
        },
        %{assigns: %{result_changesets: result_changesets}} = socket
      ) do
    result = Results.get_result!(result_id)

    case Results.update_result(result, result_params) do
      {:ok, _result} ->
        result_changesets =
          Enum.map(result_changesets, fn change ->
            if change.result_id == String.to_integer(result_id) do
              Map.put(change, :is_submitted, true)
            else
              change
            end
          end)

        socket
        |> put_flash(:info, "result added")
        |> assign(result_changesets: result_changesets)
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
          as={:choose_configurations}
          phx-value-class_id={@class.id}
          phx-change="choose_configurations"
          phx-submit="insert_total_marks"
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
            value={@subject_id}
          />
          <.input field={s[:term]} type="select" label="Choose Term" options={make_term_options()} />
          <.input
            field={s[:total_marks]}
            type="number"
            label="Total Marks"
            placeholder="should be greater than zero"
            value={@total_marks}
          />

          <.button class="mt-2">Submit Configurations</.button>
        </.form>

        <%= if @total_marks_submitted do %>
          <%= for %{name: name, changeset: changeset, result_id: result_id, is_submitted: is_submitted} <- @result_changesets, !is_submitted do %>
            <div class="relative p-5 border rounded-lg my-3">
              <.form
                :let={f}
                for={changeset}
                phx-value-result_id={result_id}
                phx-change="validate_result"
                phx-submit="add_result"
              >
                <.input
                  field={f[:obtained_marks]}
                  type="number"
                  label={"Obtained Marks of #{name} (out of #{@total_marks})"}
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

  def get_result_id(student, term, subject) do
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

      class.is_second_term_announced and class.is_third_term_announced ->
        ["Second Term": "second_term", "Third Term": "third_term"]

      class.is_third_term_announced and !class.is_first_term_announced ->
        ["Third Term": "third_term"]

      class.is_second_term_announced ->
        ["Second Term": "second_term"]

      class.is_first_term_announced and !class.is_third_term_announced ->
        ["First Term": "first_term"]

      true ->
        []
    end
  end
end
