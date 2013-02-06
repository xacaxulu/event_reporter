
class Legislator
  attr_reader :legislator

  def initialize(zipcode)
    @legislator = Sunlight::Legislator.all_in_zipcode(zipcode)
  end
end