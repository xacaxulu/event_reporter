###
# EventReporter
# by James Denman
# Completed 2/7/12
###

require 'csv'
require 'text-table'
require 'pry'

Dir.glob('*.rb').each do |f|
  require_relative f unless f == "event_reporter.rb"
end

AVAILABLE_COMMANDS = ['load <filename>', 'help', 'help <command>', 'queue count', 'queue clear', 'queue print',
                      'queue print by <attribute>', 'queue save to <filename.csv>', 'find']
COMMANDS_TO_METHODS = { 'load' => :load,
                        'find' => :find,
                        'queue count' => :queue_count,
                        'queue print by' => :queue_print_by,
                        'queue clear' => :queue_clear,
                        'queue print' => :queue_print, 
                        'queue save to' => :queue_save_to,
                        'help' => :help, 'quit' => :quit,
                        'help queue print' => :help_print }

class EventReporter
  def initialize
    puts "****************************"
    puts "EventReporter Initialized..."
    printf "Welcome to EventReporter: "
    prompt
  end

  def prompt
    puts ""
    printf "Please type a selection: "
    input = gets.chomp.downcase
    evaluate(input)
  end

  def some_method(filename)
    @contents = CSV.open(filename, headers: true, header_converters: :symbol)
  end

  def load(filename='event_attendees.csv')
    some_method(filename)
    @people = []
    @contents.each do |row|
      @people << person_build(row)
    end
    puts "Loaded #{@people.count} Records from file: '#{filename}'..."
  end

  def person_build(row)
    person = {}
    person["id"] = row[0]
    person["regdate"] = row[:regdate]
    person["first_name"] = row[:first_name].downcase.capitalize
    person["last_name"] = row[:last_name].downcase.capitalize
    person["email_address"] = row[:email_address]
    person["homephone"] = PhoneNumber.new(row[:homephone].to_s)
    person["street"] = row[:street]
    person["city"] = City.new(row[:city]).clean
    person["state"] = row[:state]
    person["zipcode"] = Zipcode.new(row[:zipcode]).clean
    person
  end

  def evaluate(input)
    if input.split(" ")[0] == "help"
      command = "help"
      args = input.split(" ")[1..-1].join(" ").split(" ")
    else
      command = COMMANDS_TO_METHODS.keys.find {|c| input.include?(c) }
      args = input.gsub(/#{command}/, '').split(" ")
    end
    do_command(command, args)
    prompt
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

  def find(*args)
    if @people.nil?
      puts "PLEASE LOAD A FILE"
      prompt
    elsif args[0] == 'city'
      attribute = args[0]
      criteria = args[1..-1].join(" ")
      @results = @people.select {|f| f[attribute].to_s.downcase == criteria.downcase }
    elsif args[0] == 'state'
      attribute = args[0]
      criteria = args[1]
      @results = @people.select {|f| f[attribute].to_s.downcase == criteria.downcase }
    else
      attribute = args[0]
      criteria = args[1..-1].join(" ")
      @results = @people.select {|f| f[attribute].to_s.downcase == criteria.downcase }
    end
    queue_print
    prompt
  end

  def queue_count
    puts ""
    if @results.nil?
      puts "Your queue count is 0:"
    else
      puts "Your queue count is #{@results.count}:"
    end
    prompt
  end

  def queue_clear
    @results = []
    sleep(3)
    puts ""
    puts "Current queue count is #{@results.length}:"
    prompt
  end

  def queue_print
    if @people.nil?
      puts "Please load a file first:"
      prompt
    else
      @results_array = @results.collect {|r| [r["id"],
        r["first_name"], r["last_name"],
        r["email_address"], r["zipcode"], r["city"],
        r["state"], r["street"], r["homephone"]] }

      table = Text::Table.new(:head => ['ID', 'FIRST_NAME',
        'LAST_NAME', 'EMAIL_ADDRESS','ZIPCODE', 'CITY', 'STATE',
        'STREET', 'HOMEPHONE'], :rows => @results_array)
      puts table
      prompt
    end  
  end

  def queue_print_by(param)
    @results_array = @results.collect {|r| [r["id"],
      r["first_name"], r["last_name"],
      r["email_address"], r["zipcode"], r["city"],
      r["state"], r["street"], r["homephone"]] }
    
    row = ['ID', 'FIRSTNAME',
     'LAST_NAME', 'EMAIL_ADDRESS','ZIPCODE', 'CITY', 'STATE',
     'STREET', 'HOMEPHONE']

    params = param.upcase!
    @index = row.index(params)
    @sorted_array = @results_array.sort_by do |i| 
      i[@index]
    end

    puts table = Text::Table.new(:head => ['ID', 'FIRSTNAME',
     'LAST_NAME', 'EMAIL_ADDRESS','ZIPCODE', 'CITY', 'STATE',
     'STREET', 'HOMEPHONE'], :rows => @sorted_array)
    @results_by_attribute = @sorted_array
    prompt
  end

  def help(*args)
    if args.any? == false
      puts ""
      puts "****HELP COMMANDS USAGE****"
      AVAILABLE_COMMANDS.each do |cmd|
        puts cmd
      end
    else
      cmd = AVAILABLE_COMMANDS.find {|i| i == args.join(" ")}
      help_print(cmd)
    end
    prompt
    puts ""
  end

  def help_print(cmd)
    puts ""
    case cmd
    when 'load <filename>'
      puts "Erases any loaded data and parse the specified file. If no filename is given, defaults to event_attendees.csv."
    when 'queue count'
      puts "Outputs how many records are in the current queue."
    when 'queue clear'
      puts "Empties the queue."
    when 'queue print'
      puts "Prints out a tab-delimited data table with a header row following this format:"
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
    if @people.nil?
      File.open(filename,'w') do |file|
        file.puts "id,regate,first_name,last_name,email_address,homephone,street,city,state,zipcode"
      end
    else
      File.open(filename,'w') do |file|
        if @results_by_attribute.nil?
          file.puts @results[0].keys.to_csv
          @results.map {|result| result.values}.each {|attrs| file.puts attrs.to_csv }
        else
          file.puts @results[0].keys.to_s.to_csv
          @results_by_attribute.map {|result| result}.each {|r| file.puts r.to_csv}
        end
      end
    end
    puts "#{filename} saved!"
    prompt
  end

  def quit
    exit
  end

end

#####
#SCRIPT

event = EventReporter.new

