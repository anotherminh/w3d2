require_relative 'questions_db'
require_relative 'QuestionFollow'

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

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.likers
    QuestionLike.likers_for_question_id(self.id)
  end

  def self.num_likes
    QuestionLike.num_likes_for_question_id(self.id)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
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
