require_relative 'question.rb'
class Reply
  attr_accessor :body, :user_id, :parent_reply_id, :question_id

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_user_id(user_id)
    QuestionsDB.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      replies
    WHERE
      user_id = ?
    SQL
  end

  def self.find_by_question_id(question_id)
    QuestionsDB.instance.execute(<<-SQL, question_id)
    SELECT
      body, user_id
    FROM
      replies
    WHERE
      question_id = ?
    SQL
  end


  def initialize(options)
    @id = options['id']
    @body = options['body']
    @parent_reply_id = options['parent_reply_id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDB.instance.execute(<<-SQL, @question_id, @parent_reply_id, @user_id, @body)
    INSERT INTO
      replies (question_id, parent_reply_id, user_id, body)
    VALUES
      (?, ?, ?, ?)
    SQL
    @id  = QuestionsDB.instance.last_insert_row_id
  end

  def update
    raise "#{self} doesn't exist" unless @id
    QuestionsDB.instance.execute(<<-SQL, @question_id, @parent_reply_id, @user_id, @body, @id)
    UPDATE
      replies
    SET
      question_id = ?, parent_reply_id = ?, user_id = ?, body = ?
    WHERE
      id = ?
    SQL
  end
end
