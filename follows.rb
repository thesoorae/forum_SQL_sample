require_relative 'questions.rb'

class Follow
  attr_accessor :user_id, :question_id

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| Follow.new(datum) }
  end

  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def create
    raise "question doesn\'t exist" unless @question_id
    raise "user doesn\'t exist" unless @user_id

    QuestionsDB.instance.execute(<<-SQL, @user_id, @question_id)
    INSERT INTO
      question_follows (user_id, question_id)
    VALUES
      (?, ?)
    SQL
  end

  def delete
    raise "question doesn\'t exist" unless @question_id
    raise "user doesn\'t exist" unless @user_id
    QuestionsDB.instance.execute(<<-SQL, @question_id, @user_id)
    DELETE FROM
      question_follows
    WHERE
      question_id = ? AND user_id = ?
    SQL
  end
end
