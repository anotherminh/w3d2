require_relative 'questions_db'

class QuestionLike < Table
  TABLE_NAME = 'question_likes'

  attr_accessor :id, :question_id, :user_id

  def initialize(attributes)
    @id = attributes['id']
    @question_id = attributes['question_id']
    @user_id = attributes['user_id']
  end
end
