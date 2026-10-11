# Free start times for a service on a given date.
#
#   AvailableSlots.new(service: service, date: Date.new(2026, 11, 2)).call
#   # => [Mon, 02 Nov 2026 10:00, Mon, 02 Nov 2026 10:15, ...]
class AvailableSlots
  STEP = 15.minutes

  def initialize(service:, date:, now: Time.current)
    @service = service
    @date = date
    @now = now
  end

  def call
    result = []

    working_intervals.each do |from, to|
      start = from

      while start + duration <= to
        if start >= now &&
           bookings.none? { it.starts_at < start + duration && start < it.ends_at }
          result << start
        end
        start += STEP
      end
    end

    result
  end

  private

  attr_reader :service, :date, :now

  def master = service.user
  def duration = service.duration_minutes.minutes

  # Working intervals for this date as [from, to] pairs of real times, sorted.
  def working_intervals
    master.availability_rules.where(weekday: date.wday).order(:start_time).map do |rule|
      [at(rule.start_time), at(rule.end_time)]
    end
  end

  # Confirmed bookings of the master that touch this date.
  def bookings
    @bookings ||= master.bookings.overlapping(date.beginning_of_day, date.end_of_day).to_a
  end

  # Rules store only the time of day (10:00); this puts it on the date.
  def at(time_of_day)
    Time.zone.local(date.year, date.month, date.day, time_of_day.hour, time_of_day.min)
  end
end
