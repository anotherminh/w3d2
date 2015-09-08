require_relative 'questions_db'

class Reply < Table
  TABLE_NAME = 'replies'

  attr_accessor :id, :question_id, :user_id, :parent_id, :body

  def self.find_by_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        #{self::TABLE_NAME}
      WHERE
        user_id = ?
    SQL

    results.map do |result|
      self.new(result)
    end
  end

  def self.find_by_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        #{self::TABLE_NAME}
      WHERE
        question_id = ?
    SQL

    results.map do |result|
      self.new(result)
    end
  end

  def initialize(attributes)
    @id = attributes['id']
    @question_id = attributes['question_id']
    @user_id = attributes['user_id']
    @parent_id = attributes['parent_id']
    @body = attributes['body']
  end

  def author
    User.find_by_id(user_id)
  end

  def question
    Question.find_by_id(question_id)
  end

  def parent_reply
    Reply.find_by_id(parent_id)
  end

  def child_replies
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{TABLE_NAME}
      WHERE
        parent_id = #{self.id}
    SQL

    results.map do |result|
      Reply.new(result)
    end
  end
end
