require_relative 'questions_db'

class User < Table
  TABLE_NAME = 'users'

  attr_accessor :id, :fname, :lname

  def self.find_by_name(fname, lname)
    results = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        #{self::TABLE_NAME}
      WHERE
        fname = ? AND lname = ?
    SQL

    results.map do |result|
      self.new(result)
    end
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(self.id)
  end

  def initialize(attributes)
    @id = attributes['id']
    @fname = attributes['fname']
    @lname = attributes['lname']
  end

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_user_id(self.id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(self.id)
  end

  def average_karma
     QuestionsDatabase.instance.execute(<<-SQL).first['karma']
      SELECT
        (CAST((COUNT(question_likes.id)) AS FLOAT)) / COUNT(DISTINCT(questions.id)) AS karma
      FROM
        questions
      LEFT OUTER JOIN
        question_likes ON questions.id = question_likes.question_id
      WHERE
        questions.author_id = #{self.id}
     SQL
  end

  
end
