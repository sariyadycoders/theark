defmodule TheArk.Classes do
  import Ecto.Query, warn: false

  alias TheArk.Repo
  alias TheArk.Classes.Class
  alias TheArk.Subjects
  alias TheArk.Subjects.Subject
  alias TheArk.Periods.Period
  alias TheArk.Attendances.Attendance

  @traits [
    %{id: 5001, label: "Punctuality_t", selected: true},
    %{id: 5002, label: "Cleanliness_t", selected: true},
    %{id: 5003, label: "Obedience_t", selected: true},
    %{id: 5004, label: "Conduct_t", selected: true},
    %{id: 5005, label: "Honesty_t", selected: true},
    %{id: 5006, label: "Responsibility_t", selected: true},
    %{id: 5007, label: "Self-Discipline_t", selected: true},
    %{id: 5008, label: "Cooperation_t", selected: true},
    %{id: 5009, label: "Confidence_t", selected: true}
  ]

  def list_classes do
    Repo.all(from(c in Class, order_by: c.id))
    |> Repo.preload([
      [
        periods: from(p in Period, order_by: p.period_number, preload: :teacher),
        subjects:
          from(s in Subject,
            where: s.is_class_subject == true,
            order_by: s.subject_id
          )
      ],
      students: [subjects: from(s in Subject, order_by: s.subject_id, preload: :results)]
    ])
  end

  def get_class!(id) do
    Repo.get!(Class, id)
    |> Repo.preload([
      [
        periods: from(p in Period, order_by: p.period_number, preload: :teacher),
        subjects:
          from(s in Subject,
            where: s.is_class_subject == true,
            order_by: s.subject_id,
            preload: :classresults
          )
      ],
      students: [subjects: from(s in Subject, order_by: s.subject_id, preload: :results)]
    ])
  end

  def get_class_for_tests_page(id) do
    Repo.get!(Class, id)
    |> Repo.preload(tests: [:result])
  end

  def get_class_for_attendance!(id, list_of_dates) do
    Repo.get!(Class, id)
    |> Repo.preload(
      students: [
        attendances: from(a in Attendance, where: a.date in ^list_of_dates)
      ]
    )
  end

  def get_class_for_teacher_collective_result(class_id, teacher_id) do
    Repo.get!(Class, class_id)
    |> Repo.preload([
      [
        subjects:
          from(s in Subject,
            where: s.is_class_subject == true and s.teacher_id == ^teacher_id,
            order_by: s.subject_id,
            preload: :classresults
          )
      ],
      students: [
        subjects:
          from(s in Subject,
            where: s.is_class_subject == false and s.teacher_id == ^teacher_id,
            order_by: s.subject_id,
            preload: :results
          )
      ]
    ])
  end

  def get_any_one_class() do
    Class |> first |> Repo.one()
  end

  def get_class_name(id) do
    Repo.one(from c in Class, where: c.id == ^id, select: c.name)
  end

  def get_all_class_ids() do
    Repo.all(from(c in Class, select: c.id))
  end

  def get_class_for_slos(id) do
    Repo.get!(Class, id)
    |> Repo.preload(:slos)
  end

  def get_class_options() do
    Repo.all(from c in Class, select: [c.name, c.id])
    |> Enum.flat_map(fn [name, id] -> ["#{name}": id] end)
  end

  def create_class(attrs \\ %{}, subject_options) do
    %Class{}
    |> Class.changeset(attrs)
    |> Repo.insert()
    |> create_class_subjects(subject_options)
  end

  def create_class_subjects({:ok, class} = success, subject_options) do
    selected_subjects =
      Enum.filter(subject_options, fn subject -> subject.selected end) ++ @traits

    for subject <- selected_subjects do
      Subjects.create_class_subject(%{
        "name" => subject.label,
        "subject_id" => subject.id,
        "class_id" => class.id,
        "is_class_subject" => "true"
      })
    end

    success
  end

  def create_class_subjects({:error, _} = error, _subject_options) do
    error
  end

  def update_class(%Class{} = class, attrs) do
    class
    |> Class.changeset(attrs)
    |> Repo.update()
  end

  def update_class(%Class{} = class, attrs, subject_options) do
    class
    |> Class.changeset(attrs)
    |> Repo.update()
    |> update_class_subjects(class, subject_options)
  end

  def update_class_subjects({:ok, _class}, class, subject_options) do
    subject_options = subject_options ++ @traits

    new_class_subject_ids =
      Enum.map(subject_options, fn subject_option ->
        if subject_option.selected, do: subject_option.id, else: 0
      end)

    prev_class_subject_ids =
      Enum.map(class.subjects, fn subject ->
        subject.subject_id
      end)

    subject_ids_to_delete =
      Enum.filter(prev_class_subject_ids, fn id ->
        id not in new_class_subject_ids
      end)

    subjects_to_delete =
      Enum.filter(subject_options, fn subject_option ->
        subject_option.id in subject_ids_to_delete
      end)

    subjects_to_update =
      Enum.filter(subject_options, fn subject_option ->
        subject_option.id not in prev_class_subject_ids and
          subject_option.id in new_class_subject_ids
      end)

    for subject <- subjects_to_delete do
      Subjects.delete_all_by_attributes(class_id: class.id, name: subject.label)
    end

    for subject <- subjects_to_update do
      Subjects.create_class_subject(%{
        "name" => subject.label,
        "subject_id" => subject.id,
        "class_id" => class.id,
        "is_class_subject" => "true"
      })

      for student <- class.students do
        Subjects.create_subject(%{
          "name" => subject.label,
          "subject_id" => subject.id,
          "class_id" => class.id,
          "student_id" => student.id
        })
      end
    end

    {:ok, class}
  end

  def update_class_subjects({:error, _} = error, _class, _subject_options) do
    error
  end

  def delete_class(%Class{} = class) do
    Repo.delete(class)
  end

  def delete_class_by_id(id) do
    class = get_class!(id)
    delete_class(class)
  end

  def change_class(%Class{} = class, attrs \\ %{}) do
    Class.changeset(class, attrs)
  end

  def term_announcement(name, type) do
    case name do
      "first_term" -> Repo.update_all(Class, set: [is_first_term_announced: type])
      "second_term" -> Repo.update_all(Class, set: [is_second_term_announced: type])
      "third_term" -> Repo.update_all(Class, set: [is_third_term_announced: type])
    end
  end

  def make_list_of_terms() do
    class = get_any_one_class()

    cond do
      class.is_first_term_announced and class.is_second_term_announced and
          class.is_third_term_announced ->
        ["first_term", "second_term", "third_term"]

      class.is_first_term_announced and class.is_second_term_announced ->
        ["first_term", "second_term"]

      class.is_second_term_announced and class.is_third_term_announced ->
        ["second_term", "third_term"]

      class.is_third_term_announced and !class.is_first_term_announced ->
        ["third_term"]

      class.is_second_term_announced ->
        ["second_term"]

      class.is_first_term_announced and !class.is_third_term_announced ->
        ["first_term"]

      true ->
        []
    end
  end
end
