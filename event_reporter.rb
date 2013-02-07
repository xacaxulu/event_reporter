###
# EventReporter
# by James Denman
# Completed 2/3/12
###

require 'csv'
require 'text-table'
require 'pry'

Dir.glob('*.rb').each do |f|
  require_relative f unless f == "event_reporter.rb"
end

AVAILABLE_COMMANDS = ['load <filename>', 'help', 'help <command>', 'queue count', 'queue clear', 'queue print',
                      'queue print by <attribute>', 'queue save to <filename.csv>', 'find']
COMMANDS_TO_METHODS = { 'load' => :database_load,
                        'find' => :find,
                        'queue count' => :queue_count,
                        'queue print by' => :queue_print_by,
                        'queue clear' => :queue_clear,
                        'queue print' => :queue_print, 
                        'queue save to' => :queue_save_to,
                        'help' => :help, 'q' => :quit }

class EventReporter
  def initialize
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

  def do_command(command, args)
    if COMMANDS_TO_METHODS[command]
      if args.any?
        send(COMMANDS_TO_METHODS[command], *args)
      else
        send(COMMANDS_TO_METHODS[command])
      end
    else
      puts "no command found" unless COMMANDS_TO_METHODS[command]
    end
  end

  def evaluate(input)
    command = COMMANDS_TO_METHODS.keys.find {|c| input.include?(c) }
    args = input.gsub(/#{command}/, '').split(" ")
    do_command(command, args)
    prompt
  end

  def find(attribute,criteria)
    attribute.downcase!
    if attribute == "city"
      criteria = criteria.split(" ").map {|word| word.downcase.capitalize}.join(" ")
    elsif attribute =~ /state/i
      criteria.upcase!
    else
      criteria.capitalize!
    end
    @results = @people.select {|f| f[attribute] == criteria }
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
        file.puts @results[0].keys.to_csv
        @results.map {|result| result.values}.each {|attrs| file.puts attrs.to_csv }
      else
        file.puts @results_by_attribute[0].keys.to_csv
          @results_by_attribute.map {|result| result.values}.each {|attrs| file.puts attrs.to_csv }
      end
    end
    prompt
  end

  def quit
    exit
  end

end

#####
#SCRIPT

event = EventReporter.new

