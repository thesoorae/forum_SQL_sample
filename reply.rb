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

  def author
   QuestionsDB.instance.execute(<<-SQL, @user_id)
    SELECT
      DISTINCT users.fname, users.lname
    FROM
      users
    JOIN
      replies ON replies.user_id = users.id
    WHERE
      users.id = ?
    SQL
  end

  def question
    QuestionsDB.instance.execute(<<-SQL, @question_id)
    SELECT
      *
    FROM
      questions
    JOIN
      replies ON questions.id = replies.question_id
    WHERE
      questions.id = ?
    SQL
  end

  def parent_reply
    QuestionsDB.instance.execute(<<-SQL, @parent_reply_id)
    SELECT
      parent_replies.body, parent_replies.user_id 
    FROM
      replies
    JOIN
      replies AS parent_replies ON replies.parent_reply_id = parent_replies.id
    WHERE
      parent_replies.id = ?
    SQL
  end

  def child_replies
    QuestionsDB.instance.execute(<<-SQL, @id)
    SELECT
      child_replies.body, child_replies.user_id
    FROM
      replies
    JOIN
      replies AS child_replies ON child_replies.parent_reply_id = replies.id
    WHERE
      child_replies.parent_reply_id = ?
    SQL
  end

end
