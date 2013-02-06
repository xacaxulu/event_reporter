class RegistrationDateTime
  attr_reader :day, :hour

  def initialize(regdate)
    @common_day = Hash.new(0)
    @common_hour = Hash.new(0)
    @registration_datetime = DateTime.strptime(regdate, '%m/%d/%y %H:%M')
  end

  def registration_hour
      @registration_datetime.hour
  end

  def registration_day
    @registration_datetime.strftime("%A")
  end

  def display_common_day
    @common_day.each {|k,v| puts "#{k} was selected as a registration day #{v} time(s)" }
  end

  def display_common_hour
    @common_hour.each {|k,v| puts "#{k}:00 hour(s) was selected as a registration hour #{v} time(s)" }
  end
end