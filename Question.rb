require_relative 'questions_db'

class Question < Table
  TABLE_NAME = 'questions'

  attr_accessor :id, :title, :body, :author_id

  def self.find_by_author_id(author_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        #{self::TABLE_NAME}
      WHERE
        author_id = ?
    SQL

    results.map do |result|
      self.new(result)
    end
  end

  def initialize(attributes)
    @id = attributes['id']
    @title = attributes['title']
    @body = attributes['body']
    @author_id = attributes['author_id']
  end

  def author
    User.find_by_id(self.author_id)
  end

  def replies
    Reply.find_by_question_id(self.id)
  end

  def followers
    QuestionFollow.followers_for_question_id(self.id)
  end
end
