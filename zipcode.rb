class Zipcode
  attr_reader :zipcode
  
  def initialize(zipcode)
    @zipcode = zipcode
  end

  def clean
    @zip = @zipcode.to_s.rjust(5,"0")[0..4]
  end
end