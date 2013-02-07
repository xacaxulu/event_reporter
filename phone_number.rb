class PhoneNumber
  INVALID_NUMBER = "0000000000"

  def initialize(number)
    @number = number
  end

  def clean
    phone_number = @number.gsub(/[-., ]/,"")
    cleaned_number = ""
    if phone_number.nil? || phone_number == ""
      cleaned_number = INVALID_NUMBER
    elsif phone_number.length == 10
      cleaned_number = phone_number
    elsif phone_number.length == 11 && phone_number[0] == "1"
      cleaned_number = phone_number[1..-1]
    elsif phone_number.length == 11 && phone_number[0] != "1"
      cleaned_number = INVALID_NUMBER
    elsif phone_number.length >= 12
      cleaned_number = INVALID_NUMBER
    end
    cleaned_number
  end
end