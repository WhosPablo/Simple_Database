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
    db = SimpleDatabase.new         # New database object
    db_console = DBConsole.new      # New database console object
    db_console.run(db)              # Run database console on database
}



=begin

  DBConsole

  handles communication between STDIN/STDOUT and database

  Methods
  --------------
    run:
      runs console on specified database
    evaluate_io:
      evaluates commands from standerd input and outputs results on standard output  
=end
class DBConsole

  def run (database)
    STDIN.each_line do |l|
      inputOutput(database, l)          # For each line in the standard input,
    end                                 #  evaluate data and handle output.
  end

  def inputOutput(db, input)
    cmd = input.split(' ')              #split line into separate arguments
    case cmd [0]
      when "END"
        abort()                         #exit program if command is end
      when "SET"
        db.set(cmd[1], cmd[2])
      when "GET"                        #if command GET then pri
        value = db.get(cmd[1])
        unless value
          puts "NULL"                   # Print NULL if db.get(key) returns nil
        else
          puts value
        end
      when "UNSET"
        db.unset(cmd[1])
      when "NUMEQUALTO"
        puts db.numEqualTo(cmd[1])
      when "BEGIN"
        db.begin()
      when "ROLLBACK"                               # Prints NO TRANSACTION if 
        puts "NO TRANSACTION" unless db.rollback()  # db.rollback() returns FALSE
      when "COMMIT"                                 # Prints NO TRANSACTION if
        puts "NO TRANSACTION" unless db.commit()    # db.commit() returns FALSE
      else
        if cmd[0]
          puts "Invalid command " + cmd[0]          # Prints invalid command if
        else                                        # command is not recognized
          puts "No command"                         # else prints no command
        end
    end
  end
end


=begin

  SimpleDatabase

  Main database object does not handle any STDIN/STDOUT

  Variables
  -------------
    database:
        holds the working database with all changes
    transaction:
        holds dictionaries with changes that can be rolled back to 
        if necessary and cleared when commiting changes

  Methods
  --------------
    set(name, value):
        Check for transaction_block and save value before changes, then save
        value to database with name as the key.
    get(name):
        Return the value of the variable name, or nil if that variable 
        is not set.
    unset(name):
        Unset the variable name, making it just like that variable was 
        never set.
    numEqualTo(value):
        Print out the number of variables that are currently set 
        to value. If no variables equal that value, print 0.
    begin:
        Open a new transaction block. Transaction blocks can be nested; a 
        BEGIN can be issued inside of an existing block.
    rollback:
        Undo all of the commands issued in the most recent transaction block, 
        and close the block. Print nothing if successful, or return FALSE
        if no transaction is in progress.
    commit:
        Close all open transaction blocks, permanently applying the changes 
        made in them. Return FALSE if no transaction is in progress.

=end
class SimpleDatabase

  attr_accessor :database, :transaction_block

  def initialize
    @database = {}                        #Main Databse
    @transaction_block = []               #represents history of changes
  end

  def set (name, value)
    if transaction_block.last             #check for a last transaction
      unless transaction_block.last[name]
        transaction_block.last[name] =
          database[name]                  #save value before changes
      end
    end   
    database[name] = value                #set value in database
  end

  def get (name)
    value = database[name]  
    if value.nil? 
      return nil                          #return nill if no vale found
    else
      return value                        #return value
    end
  end

  def unset (name)
    if transaction_block.last             #check for a last transaction
      unless transaction_block.last[name]
        transaction_block.last[name] =
          database[name]                  #save value before changes
      end
    end
    database.delete(name)                 #delete value in database
  end

  def numEqualTo (value)
    return database.values.count(value)   #return number of variables set to value
  end

  def begin
    transaction_block << {}               #create a new transaction block history
  end

  def rollback
    if transaction_block.empty?
      return false                        #return false if NO TRANSACTION
    end

    database.merge!(transaction_block.pop)#remove changes from last transaction 
    database.delete_if{|k,v| v==nil}      #delete values that were erased when rolling back
  end

  def commit
    if transaction_block.empty?
      return false                        #return false if NO TRANSACTION
    end
    transaction_block.clear               #clear history of changes
  end
end


