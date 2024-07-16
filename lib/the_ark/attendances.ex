defmodule TheArk.Attendances do
  @moduledoc """
  The Attendances context.
  """

  import Ecto.Query, warn: false
  alias TheArk.Students.Student
  alias TheArk.Classes
  alias TheArk.Students
  alias TheArk.Repo
  alias TheArk.Attendances.Attendance
  alias TheArk.Shared

  @doc """
  Returns the list of attendances.

  ## Examples

      iex> list_attendances()
      [%Attendance{}, ...]

  """
  def list_attendances do
    Repo.all(Attendance)
  end

  @doc """
  Gets a single attendance.

  Raises `Ecto.NoResultsError` if the Attendance does not exist.

  ## Examples

      iex> get_attendance!(123)
      %Attendance{}

      iex> get_attendance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_attendance!(id), do: Repo.get!(Attendance, id)

  def get_one_attendance(student_id, date) do
    Repo.one(from(a in Attendance, where: a.student_id == ^student_id and a.date == ^date))
  end

  def get_counts_of_attendance_for_class(class_id, list_of_dates, entry) do
    Repo.aggregate(
      from(a in Attendance,
        join: s in Student,
        on: a.student_id == s.id,
        where: s.class_id == ^class_id,
        where: a.date in ^list_of_dates,
        where: a.entry == ^entry
      ),
      :count
    )
  end

  def get_counts_of_attendance_for_student(student_id, list_of_dates, entry) do
    Repo.aggregate(
      from(a in Attendance,
        where: a.student_id == ^student_id,
        where: a.date in ^list_of_dates,
        where: a.entry == ^entry
      ),
      :count
    )
  end

  def get_list_of_attendance_dates(student_id, list_of_dates, entry) do
    from(
      a in Attendance,
      where: a.student_id == ^student_id,
      where: a.date in ^list_of_dates,
      where: a.entry == ^entry,
      select: a.date
    )
    |> Repo.all()
  end

  def get_monthly_attendance_of_class(class_id, month_number, year) do
    Repo.one(
      from(a in Attendance,
        where: a.class_id == ^class_id,
        where: a.month_number == ^month_number,
        where: a.is_monthly == true,
        where: a.year == ^year
      )
    )
  end

  def get_monthly_attendance_of_student(student_id, month_number, year) do
    Repo.one(
      from(a in Attendance,
        where: a.student_id == ^student_id,
        where: a.month_number == ^month_number,
        where: a.is_monthly == true,
        where: a.year == ^year
      )
    )
  end

  def get_student_monthly_attendances_to_show(student_id) do
    Repo.all(
      from(
        a in Attendance,
        where: a.student_id == ^student_id,
        where: a.is_monthly == true,
        order_by: a.month_number
      )
    )
  end

  @doc """
  Creates a attendance.

  ## Examples

      iex> create_attendance(%{field: value})
      {:ok, %Attendance{}}

      iex> create_attendance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_attendance(attrs \\ %{}) do
    %Attendance{}
    |> Attendance.changeset(attrs)
    |> Repo.insert()
  end

  def create_next_month_attendances(current_month_number, class_id) do
    next_month_number = if current_month_number == 12, do: 1, else: current_month_number + 1

    beginning_of_next_month = Shared.first_date_of_month(Timex.month_name(next_month_number))

    for student_id <- Students.get_all_active_students_ids(class_id) do
      for day_number <- 1..Timex.days_in_month(beginning_of_next_month) do
        date = Date.add(beginning_of_next_month, day_number - 1)
        entry = "Not Marked Yet"
        prev_attendance = get_one_attendance(student_id, date)

        if !prev_attendance,
          do: create_attendance(%{date: date, entry: entry, student_id: student_id})
      end
    end
  end

  def create_monthly_attendances(current_month_number) do
    beginning_of_month = Shared.first_date_of_month(Timex.month_name(current_month_number))

    days = Timex.days_in_month(beginning_of_month)

    list_of_dates =
      Enum.map(1..days, fn num ->
        Date.add(beginning_of_month, num - 1)
      end)

    for class_id <- Classes.get_all_class_ids() do
      number_of_absents = get_counts_of_attendance_for_class(class_id, list_of_dates, "Absent")
      number_of_leaves = get_counts_of_attendance_for_class(class_id, list_of_dates, "Leave")

      number_of_half_leaves =
        get_counts_of_attendance_for_class(class_id, list_of_dates, "Half Leave")

      monthly_attendance_of_class =
        get_monthly_attendance_of_class(class_id, current_month_number, beginning_of_month.year)

      if monthly_attendance_of_class do
        update_attendance(monthly_attendance_of_class, %{
          number_of_leaves: number_of_leaves,
          number_of_absents: number_of_absents,
          number_of_half_leaves: number_of_half_leaves,
          year: beginning_of_month.year
        })

        for student_id <- Students.get_all_active_students_ids(class_id) do
          number_of_absents =
            get_counts_of_attendance_for_student(student_id, list_of_dates, "Absent")

          absent_days = get_list_of_attendance_dates(student_id, list_of_dates, "Absent")

          number_of_leaves =
            get_counts_of_attendance_for_student(student_id, list_of_dates, "Leave")

          leave_days = get_list_of_attendance_dates(student_id, list_of_dates, "Leave")

          number_of_half_leaves =
            get_counts_of_attendance_for_student(student_id, list_of_dates, "Half Leave")

          half_leave_days = get_list_of_attendance_dates(student_id, list_of_dates, "Half Leave")

          monthly_attendance_of_student =
            get_monthly_attendance_of_student(
              student_id,
              current_month_number,
              beginning_of_month.year
            )

          if monthly_attendance_of_student do
            update_attendance(monthly_attendance_of_student, %{
              number_of_leaves: number_of_leaves,
              leave_days: leave_days,
              number_of_absents: number_of_absents,
              absent_days: absent_days,
              number_of_half_leaves: number_of_half_leaves,
              half_leave_days: half_leave_days,
              is_monthly: true,
              year: beginning_of_month.year,
              month_number: current_month_number,
              student_id: student_id
            })
          else
            create_attendance(%{
              number_of_leaves: number_of_leaves,
              leave_days: leave_days,
              number_of_absents: number_of_absents,
              absent_days: absent_days,
              number_of_half_leaves: number_of_half_leaves,
              half_leave_days: half_leave_days,
              is_monthly: true,
              month_number: current_month_number,
              year: beginning_of_month.year,
              student_id: student_id
            })
          end
        end
      else
        create_attendance(%{
          number_of_leaves: number_of_leaves,
          number_of_absents: number_of_absents,
          number_of_half_leaves: number_of_half_leaves,
          is_monthly: true,
          month_number: current_month_number,
          year: beginning_of_month.year,
          class_id: class_id
        })

        for student_id <- Students.get_all_active_students_ids(class_id) do
          number_of_absents =
            get_counts_of_attendance_for_student(student_id, list_of_dates, "Absent")

          absent_days = get_list_of_attendance_dates(student_id, list_of_dates, "Absent")

          number_of_leaves =
            get_counts_of_attendance_for_student(student_id, list_of_dates, "Leave")

          leave_days = get_list_of_attendance_dates(student_id, list_of_dates, "Leave")

          number_of_half_leaves =
            get_counts_of_attendance_for_student(student_id, list_of_dates, "Half Leave")

          half_leave_days = get_list_of_attendance_dates(student_id, list_of_dates, "Half Leave")

          create_attendance(%{
            number_of_leaves: number_of_leaves,
            leave_days: leave_days,
            number_of_absents: number_of_absents,
            absent_days: absent_days,
            number_of_half_leaves: number_of_half_leaves,
            half_leave_days: half_leave_days,
            is_monthly: true,
            month_number: current_month_number,
            year: beginning_of_month.year,
            student_id: student_id
          })
        end
      end

      create_next_month_attendances(current_month_number, class_id)
    end
  end

  @doc """
  Updates a attendance.

  ## Examples

      iex> update_attendance(attendance, %{field: new_value})
      {:ok, %Attendance{}}

      iex> update_attendance(attendance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_attendance(%Attendance{} = attendance, attrs) do
    attendance
    |> Attendance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a attendance.

  ## Examples

      iex> delete_attendance(attendance)
      {:ok, %Attendance{}}

      iex> delete_attendance(attendance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_attendance(%Attendance{} = attendance) do
    Repo.delete(attendance)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking attendance changes.

  ## Examples

      iex> change_attendance(attendance)
      %Ecto.Changeset{data: %Attendance{}}

  """
  def change_attendance(%Attendance{} = attendance, attrs \\ %{}) do
    Attendance.changeset(attendance, attrs)
  end
end
