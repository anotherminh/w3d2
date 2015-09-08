require_relative 'questions_db'

class QuestionFollow < Table
  TABLE_NAME = 'question_follows'

  attr_accessor :id, :user_id, :question_id

  def self.followers_for_question_id(question_id)
    users_following = QuestionsDatabase.instance.execute(<<-SQL, question_id)
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
    followed_questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
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

  def initialize(attributes)
    @id = attributes['id']
    @user_id = attributes['user_id']
    @question_id = attributes['question_id']
  end
end
