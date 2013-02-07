class PhoneNumber
  INVALID_NUMBER = "0000000000"
  def initialize number
    @number = number
    @number = number.gsub(/\D/,"")
    clean
  end

  def clean
    if has_11_digits? and starts_with_1?
      @number = @number[1..-1] 
    elsif invalid_length?
      @number = nil
    end
  end

  def to_s
    @number.nil? ? "No Number" : @number
  end

  def starts_with_1?
    @number[0].to_i == 1
  end

  def has_11_digits?
    @number.length == 11
  end

  def invalid_length?
    @number.length != 10
  end

  def valid?(number)
    !number.nil?
  end

end