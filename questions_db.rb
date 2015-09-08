require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.results_as_hash = true
    self.type_translation = true
  end
end

class Table
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id).first
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
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self::TABLE_NAME}
    SQL

    results.map { |result| self.new(result) }
  end

  def save
    instance_variables = self.instance_variables.map do |var|
      var.to_s[1..-1].to_sym
    end.reject{ |var| var == :id }

    set_string = instance_variables.map do |var|
      "#{var} = :#{var}"
    end.join(", ")

    actual_values = Hash.new

    instance_variables.each do |var|
      actual_values[var] = self.send(var)
    end

    var_list = instance_variables.map do |var|
      var.to_s
    end.join(", ")

    val_list = instance_variables.map do |var|
      ":" + var.to_s
    end.join(", ")

    if self.id
      QuestionsDatabase.instance.execute(<<-SQL, actual_values)
        UPDATE
          #{self.class::TABLE_NAME}
        SET
          #{set_string}
        WHERE
          id = #{self.id}
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, actual_values)
        INSERT INTO
          #{self.class::TABLE_NAME}(#{var_list})
        VALUES
          (#{val_list})
      SQL

      self.id = QuestionsDatabase.instance.last_insert_row_id
    end
  end
end
