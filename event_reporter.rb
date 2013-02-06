###
# EventReporter
# by James Denman
# Completed 2/3/12
###

require 'csv'
require 'sunlight'
require 'text-table'

Dir.glob('*.rb').each do |f|
  require_relative f unless f == "event_reporter.rb"
end

AVAILABLE_COMMANDS = ['load <filename>', 'help', 'help <command>', 'queue count', 'queue clear', 'queue print',
                      'queue print by <attribute>', 'queue save to <filename.csv>', 'find <attribute> <criteria>']

class EventReporter
  def initialize
    Sunlight::Base.api_key = "e179a6973728c4dd3fb1204283aaccb5"
    puts "****************************"
    puts "EventReporter Initialized..."
    prompt
  end

  def prompt
    puts ""
    printf "Welcome to EventReporter: please type a selection: "
    input = gets.chomp.downcase
    evaluate(input)
  end


  def database_load(arg='event_attendees.csv')
    @contents = CSV.open(arg, headers: true, header_converters: :symbol)
    @people = []
    @contents.each do |row|
      person = {}
      person["id"] = row[0]
      person["regdate"] = row[:regdate]
      person["first_name"] = row[:first_name].downcase.capitalize
      person["last_name"] = row[:last_name].downcase.capitalize
      person["email"] = row[:email_address]
      person["phone"] = PhoneNumber.new(row[:homephone]).clean
      person["address"] = row[:street]
      person["city"] = City.new(row[:city]).clean
      person["state"] = row[:state]
      person["zipcode"] = Zipcode.new(row[:zipcode]).clean
      @people << person
    end
    puts "Loaded #{@people.count} Records from file: '#{arg}'..."
  end

  def evaluate(input)
    parts = input.split(" ")
    command = parts
    if command[0] == 'help'
      help(command[1..-1].join(" "))
    elsif command[0] == 'load' && command[1].nil?
      database_load
      prompt
    elsif command[0] == 'load' && !command[1].nil?
      database_load(command[1])
      prompt
    elsif command[0] == 'find'
      find(command[1],command[2..3].join(" "))
    elsif command[0] == 'queue' && command[1] == 'count'
      queue_count
    elsif command[0] == 'queue' && command[1] == 'clear'
      queue_clear
    elsif command[0] == 'queue' && command[1] == 'print' && command[2].nil?
      queue_print
    elsif command[0] == 'queue' && command[1..2].join(" ") == "print by"
      queue_print_by(command[3])
    elsif command[0] == 'queue' && command[1..2].join(" ") == "save to"
      queue_save_to(command[3])
    elsif command[0] == 'q'
    else
      prompt
    end
  end

  def find(attribute,criteria)
    @attribute = attribute.downcase
    if @attribute == "state"
      @criteria = criteria.upcase
    else
      @criteria = criteria.capitalize
    end
    @results = @people.select {|f| f[@attribute] == @criteria }
    puts @results
    prompt
  end


  def queue_count
    if @results.nil?
      puts "queue count is 0"
    else
      puts "queue count is #{@results.count}"
    end
    prompt
  end

  def queue_clear
    @results = []
    sleep(3)
    if @results.nil?
      puts "Current queue count is 0"
    else
      puts "Current queue count is #{@results.length}"
    end
    prompt
  end

  def queue_print
    @results_array = @results.collect {|r| [r["id"],
      r["first_name"], r["last_name"],
      r["email"], r["zipcode"], r["city"],
      r["state"], r["address"], r["phone"]] }
    
    table = Text::Table.new(:head => ['ID', 'FIRSTNAME',
      'LASTNAME', 'EMAIL','ZIPCODE', 'CITY', 'STATE',
      'ADDRESS', 'PHONE'], :rows => @results_array)
    puts table
    prompt  
  end

  def queue_print_by(param)
    @results_array = @results.collect {|r| [r["id"],
      r["first_name"], r["last_name"],
      r["email"], r["zipcode"], r["city"],
      r["state"], r["address"], r["phone"]] }
    row = ['ID', 'FIRST_NAME',
      'LAST_NAME', 'EMAIL','ZIPCODE', 'CITY', 'STATE',
      'ADDRESS', 'PHONE']
    params = param.upcase!
    @index = row.index(params)
    @sorted_array = @results_array.sort_by do |i| 
      i[@index]
    end
    
    puts table = Text::Table.new(:head => ['ID', 'FIRSTNAME',
      'LASTNAME', 'EMAIL','ZIPCODE', 'CITY', 'STATE',
      'ADDRESS', 'PHONE'], :rows => @sorted_array)
    @results_by_attribute = @sorted_array
    prompt
  end

  def help(args="")
    if args.length >= 1
      puts ""
      puts "****HELP COMMANDS USAGE****"
      cmd = AVAILABLE_COMMANDS.find {|i| i == args}
      help_print(cmd)
    else
      AVAILABLE_COMMANDS.each do |cmd|
        puts cmd
      end
      prompt
    end
    puts ""
  end
  
  def help_print(cmd)
    case cmd
    when 'load <filename>'
      puts "Erases any loaded data and parse the specified file. If no filename is given, defaults to event_attendees.csv."
    when 'queue count'
      puts "Outputs how many records are in the current queue."
    when 'queue clear'
      puts "Empties the queue."
    when 'queue print'
      puts "Print out a tab-delimited data table with a header row following this format:"
      puts "ID LAST NAME  FIRST NAME  EMAIL  ZIPCODE  CITY  STATE  ADDRESS  PHONE"
    when 'queue print by <attribute>'
      puts "Print the data table sorted by the specified attribute like zipcode."
    when 'queue save to <filename.csv>'
      puts "Exports the current queue to the specified filename as a CSV."
    when 'find'
      puts "Load the queue with all records matching the criteria for the given attribute: example: find state nd"
    end
    prompt
  end

  def queue_save_to(filename)
    filename = "#{filename}"
    File.open(filename,'w') do |file|
      if @results_by_attribute.nil?
        file.puts @results.to_csv
      else
        file.puts @results_by_attribute.to_csv
      end
    end
    prompt
  end
end

#####
#SCRIPT

event = EventReporter.new

