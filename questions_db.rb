require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def self.execute(*args)
    QuestionsDatabase.instance.execute(*args)
  end

  def initialize
    super('questions.db')
    self.results_as_hash = true
    self.type_translation = true
  end
end

class Table
  def self.find_by_id(id)
    results = QuestionsDatabase.execute(<<-SQL, id).first
      SELECT
        *
      FROM
        #{self::TABLE_NAME}
      WHERE
        id = ?
    SQL

    self.new(results)
  end

  def self.all
    results = QuestionsDatabase.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self::TABLE_NAME}
    SQL

    results.map { |result| self.new(result) }
  end

  def self.where(input)

    if input.is_a?(Hash)
      results = self.hash_where(input)
    else
      results = self.string_where(input)
    end

    results.map { |result| self.new(result) }
  end

  def self.hash_where(opt_hash)
    where_string = self.make_where_string(opt_hash.keys)
    results = QuestionsDatabase.execute(<<-SQL, input)
      SELECT
        *
      FROM
        #{self::TABLE_NAME}
      WHERE
        #{where_string}
    SQL

  end

  def self.string_where(string)
    results = QuestionsDatabase.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self::TABLE_NAME}
      WHERE
        #{string}
    SQL
  end

  def self.make_where_string(var)
    var.map do |var|
      "#{var} = :#{var}"
    end.join(" AND ")
  end

  def self.parse_method_name(name)
    without_find_by = name.to_s.chars.drop(8).join
    columns = without_find_by.split('_and_')
  end

  def self.method_missing(symbol, *args)
    raise 'method missing' unless symbol.to_s.start_with?('find_by_')
    columns = self.parse_method_name(symbol)

    opt_hash = Hash.new

    columns.each_with_index do |col, idx|
      opt_hash[col] = args[idx]
    end

    self.where(opt_hash)
  end

  def get_instance_variables_as_sym
    instance_variables = self.instance_variables.map do |var|
      var.to_s[1..-1].to_sym
    end.reject{ |var| var == :id }
  end

  def make_set_string(var)
    var.map do |var|
      "#{var} = :#{var}"
    end.join(", ")
  end

  def save
    instance_variables = get_instance_variables_as_sym
    set_string = make_set_string(instance_variables)

    actual_values = Hash.new
    instance_variables.each do |var|
      actual_values[var] = self.send(var)
    end

    var_list = instance_variables.map { |var| var.to_s }.join(", ")
    val_list = instance_variables.map { |var| ":" + var.to_s }.join(", ")

    if self.id
      update(actual_values, set_string)
    else
      insert(actual_values, var_list, val_list)
    end
  end

  def update(values, set_string)
    QuestionsDatabase.execute(<<-SQL, values_hash)
      UPDATE
        #{self.class::TABLE_NAME}
      SET
        #{set_string}
      WHERE
        id = #{self.id}
    SQL
  end

  def insert(values_hash, variables, values)
    QuestionsDatabase.execute(<<-SQL, values_hash)
      INSERT INTO
        #{self.class::TABLE_NAME}(#{variables})
      VALUES
        (#{values})
    SQL

    self.id = QuestionsDatabase.instance.last_insert_row_id
  end
end
