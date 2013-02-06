class City
  attr_reader :city
  
  def initialize(city)
    @city = city
  end

  def clean
    if @city.nil?
      @city = "NoEntry"
    else
      @city.downcase.capitalize
    end
  end


end