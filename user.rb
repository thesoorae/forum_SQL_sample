require_relative 'question.rb'
require_relative 'like.rb'


class User
  attr_accessor :fname, :lname

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_name(fname, lname)
    QuestionsDB.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    WHERE
      fname = ? AND lname = ?
    SQL
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDB.instance.execute(<<-SQL, @fname, @lname)
    INSERT INTO
      users (fname, lname)
    VALUES
      (?, ?)
    SQL
    @id  = QuestionsDB.instance.last_insert_row_id
  end

  def update
    raise "#{self} doesn't exist" unless @id
    QuestionsDB.instance.execute(<<-SQL, @fname, @lname, @id)
    UPDATE
      users
    SET
      fname = ?, lname = ?
    WHERE
      id = ?
    SQL
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    Follow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    Like.likers_for_user_id(@id)
  end

  def average_karma
    QuestionsDB.instance.execute(<<-SQL, @id)
    SELECT
      CAST(COUNT(question_likes.question_id) AS FLOAT) / COUNT(DISTINCT questions.id) AS karma
    FROM
      questions
    LEFT OUTER JOIN
      question_likes ON questions.id = question_likes.question_id
    WHERE
      questions.user_id = ?
    SQL
  end

end
