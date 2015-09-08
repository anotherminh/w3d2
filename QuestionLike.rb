require_relative 'questions_db'
require_relative 'User'

class QuestionLike < Table
  TABLE_NAME = 'question_likes'

  attr_accessor :id, :question_id, :user_id

  def self.likers_for_question_id(question_id)
    likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        users
      JOIN
        question_likes ON users.id = question_likes.user_id
      JOIN
        questions ON question_likes.question_id = questions.id
      WHERE
        questions.id = ?
    SQL

    likers.map do |liker|
      User.new(liker)
    end
  end

  def self.num_likes_for_question_id(question_id)
    QuestionsDatabase.instance.execute(<<-SQL, question_id).first['count']
      SELECT
        COUNT(*) as count
      FROM
        questions
      JOIN
        question_likes ON question_likes.question_id = questions.id
      JOIN
        users ON users.id = question_likes.user_id
      WHERE
        questions.id = ?
      GROUP BY
        questions.id
    SQL
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_likes ON question_likes.question_id = questions.id
      JOIN
        users ON users.id = question_likes.user_id
      WHERE
        users.id = ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.*
      FROM
        questions
      JOIN
        question_likes ON question_likes.question_id = questions.id
      JOIN
        users ON users.id = question_likes.user_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(users.id) DESC
      LIMIT ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def initialize(attributes)
    @id = attributes['id']
    @question_id = attributes['question_id']
    @user_id = attributes['user_id']
  end
end
