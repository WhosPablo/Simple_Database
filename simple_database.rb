#!/usr/bin/env ruby

=begin

  simple_database.rb

  Simple Database Challenge
  Database Commands:
    Data Commands:
   * SET name value – Set the variable name to the value value. Neither variable 
     names nor values will contain spaces.
   * GET name – Print out the value of the variable name, or NULL if that variable 
     is not set.
   * UNSET name – Unset the variable name, making it just like that variable was 
     never set.
   * NUMEQUALTO value – Print out the number of variables that are currently set 
     to value. If no variables equal that value, print 0.
   * END – Exit the program. Your program will always receive this as its last 
     command.

    Transaction Commands:
   * BEGIN – Open a new transaction block. Transaction blocks can be nested; a 
     BEGIN can be issued inside of an existing block.
   * ROLLBACK – Undo all of the commands issued in the most recent transaction 
     block, and close the block. Print nothing if successful, or print NO 
     TRANSACTION if no transaction is in progress.
   * COMMIT – Close all open transaction blocks, permanently applying the changes 
     made in them. Print nothing if successful, or print NO TRANSACTION if no 
     transaction is in progress.

  @author 
  Pablo Arango
  arangopablo@icloud.com

=end


# Allows for declaring functions at the bottom so that the code looks more
# organized
END {
  db = SimpleDatabase.new     # New database object
  db_console = DBConsole.new  # New database console object
  db_console.run(db)          # Run database console on database
}

=begin

  DBConsole

  handles communication between STDIN/STDOUT and database

=end

class DBConsole

  def run (database)
    STDIN.each_line do |l|
      evaluate_io(database, l) # For each line in the standard input,
    end                        # evaluate data and handle output.
  end

  def evaluate_io(db, input)
    cmd = input.split(' ')                #split line into separate arguments
    case cmd [0]
      when 'END'
        abort
      when 'SET'
        db.set(cmd[1], cmd[2])
      when 'GET'
        value = db.get(cmd[1])
        if value.nil?
          puts 'NULL'
        else
          puts value
        end
      when 'UNSET'
        db.unset(cmd[1])
      when 'NUMEQUALTO'
        puts db.num_equal_to(cmd[1])
      when 'BEGIN'
        db.begin
      when 'ROLLBACK'
        puts 'NO TRANSACTION' unless db.rollback
      when 'COMMIT'
        puts 'NO TRANSACTION' unless db.commit
      else
        if cmd[0]
          puts 'Invalid command ' + cmd[0]  # Prints invalid command if
        else                                # command is not recognized
          puts 'No command'                 # else prints no command
        end
    end
  end
end


=begin

  SimpleDatabase

  Main database object. Does not handle any STDIN/STDOUT

=end

class SimpleDatabase

  def initialize
    @database = {}             #Main Database
    @database_value_count = {} #counts of each value
    @transaction_block = []    #represents history of changes
  end

  def set (name, value)
    save_previous_if_transaction(name)
    set_databases(name, value)
  end

  def unset (name)
    if get(name).nil?
      return true
    end
    save_previous_if_transaction(name)
    unset_databases(name)
  end

  def get (name)
    @database[name]
  end

  def num_equal_to (value)
    value = get_count(value)
    value.nil? ? 0 : value
  end

  def begin
    @transaction_block.push({})                     #create a new transaction block history
  end

  def rollback
    if @transaction_block.empty?
      return false
    end

    @transaction_block.pop.each do |name, oldvalue| #remove changes from last transaction
      if oldvalue.nil?
        unset_databases(name)
      else
        set_databases(name, oldvalue)
      end
    end

  end

  def commit
    if @transaction_block.empty?
      return false
    end
    @transaction_block.clear                      #clear history of changes
  end


  private # Private Methods ------------------------------------------

  def save_previous_if_transaction (name)
    if @transaction_block.last
      unless @transaction_block.last[name]
        @transaction_block.last[name] = get(name) #save value before changes
      end
    end
  end

  def set_databases(name, value)
    dec_or_del_count_if_present(get(name))    #decrement count of previous value
    @database[name] = value                   #set value in database
    inc_or_create_count(value)                #increment count of new value
  end

  def unset_databases(name)
    dec_or_del_count_if_present(get(name))    #decrement count of previous value
    @database.delete(name)                    #delete value in database
  end

  def get_count(value)
    @database_value_count[value]
  end

  def dec_or_del_count_if_present (value)
    unless get_count(value).nil?
      @database_value_count[value] -= 1
      if get_count(value) <= 0
        @database_value_count.delete(value)
      end
    end
  end

  def inc_or_create_count (value)
    if get_count(value).nil?
      @database_value_count[value] = 1
    else
      @database_value_count[value] += 1
    end
  end
end


