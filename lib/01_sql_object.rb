require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    unless @columns
      table = DBConnection.execute2(<<-SQL)
      SELECT
      *
      FROM
      #{table_name}
      SQL
      table_strings = table.first
      @columns = []
      table_strings.each do |column|
        @columns << column.to_sym
      end
    end
    @columns
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        self.attributes[column]
      end
      define_method("#{column}=") do |val|
        self.attributes[column]= val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name.to_s.tableize
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    all = DBConnection.execute2(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(all[1..-1])
  end

  def self.parse_all(results)
    results.map{|result| self.new(result)}
  end

  def self.find(id)
    result = DBConnection.execute2(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL
    found = result[1]
    return nil if found.nil?
    self.new(found)
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      attr_name = attr_name.to_sym
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      else
        self.send("#{attr_name}=" , val)
      end
    end
  end

  def attributes
    @attributes ||= @attributes = {}
  end

  def attribute_values
    self.class.columns.map {|attribute| self.send(attribute)}
  end

  def insert
    col_names = self.class.columns.join(",")
    marks = ["?"] * (self.class.columns.length)
    question_marks = marks.join(",")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      Values
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    line = self.class.columns.map { |attr| "#{attr} = ?" }.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{line}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

  def save
    self.id.nil? ? insert : update
  end
end
