class LastDayNextDay

  def self.last(day)
    days = {
      "monday"    => 1,
      "tuesday"   => 2,
      "wednesday" => 3,
      "thursday"  => 4,
      "friday"    => 5,
      "saturday"  => 6,
      "sunday"    => 7
    }
    today_integer = Date.today.cwday
    last_day_integer = days[day]
    if today_integer > last_day_integer
      difference = today_integer - last_day_integer
    elsif today_integer == last_day_integer
      difference = 7
    else
      difference = today_integer + 7 - last_day_integer
    end
    difference.days.ago.to_date
  end
  
  def self.next(day)
    days = {
      "monday"    => 1,
      "tuesday"   => 2,
      "wednesday" => 3,
      "thursday"  => 4,
      "friday"    => 5,
      "saturday"  => 6,
      "sunday"    => 7
    }
    today_integer = Date.today.cwday
    next_day_integer = days[day]
    if next_day_integer > today_integer
      difference = next_day_integer - today_integer
    elsif next_day_integer == today_integer
      difference = 7
    else
      difference = next_day_integer + 7 - today_integer
    end
    difference.days.from_now.to_date
  end

end