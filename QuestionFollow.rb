require_relative 'questions_db'
require_relative 'question'

class QuestionFollow < Table
  TABLE_NAME = 'question_follows'

  attr_accessor :id, :user_id, :question_id

  def self.followers_for_question_id(question_id)
    users_following = QuestionsDatabase.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        #{self::TABLE_NAME}
      JOIN
        users ON user_id = users.id
      WHERE
        question_id = ?
    SQL

    users_following.map do |user|
      User.new(user)
    end
  end

  def self.followed_questions_for_user_id(user_id)
    followed_questions = QuestionsDatabase.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        #{TABLE_NAME}
      JOIN
        questions ON question_id = questions.id
      WHERE
        user_id = ?
    SQL

    followed_questions.map do |question|
      Question.new(question)
    end
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_follows ON questions.id = question_follows.question_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(*) DESC
      LIMIT ?
    SQL

    questions.map do |question|
      Question.new(question)
    end
  end

  def initialize(attributes)
    @id = attributes['id']
    @user_id = attributes['user_id']
    @question_id = attributes['question_id']
  end
end
