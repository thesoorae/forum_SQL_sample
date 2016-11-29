require_relative 'questions.rb'

class Like
  attr_accessor :user_id, :question_id

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| Like.new(datum) }
  end

  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def like
    raise "question doesn\'t exist" unless @question_id
    raise "user doesn\'t exist" unless @user_id

    QuestionsDB.instance.execute(<<-SQL, @user_id, @question_id)
    INSERT INTO
      question_likes (user_id, question_id)
    VALUES
      (?, ?)
    SQL
  end

  def unlike
    raise "question doesn\'t exist" unless @question_id
    raise "user doesn\'t exist" unless @user_id
    QuestionsDB.instance.execute(<<-SQL, @question_id, @user_id)
    DELETE FROM
      question_likes
    WHERE
      question_id = ? AND user_id = ?
    SQL
  end
end
