
class Like
  attr_accessor :user_id, :question_id

  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| Like.new(datum) }
  end

  def self.likers_for_question_id(question_id)
    QuestionsDB.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      users
    JOIN
      question_likes ON question_likes.user_id = users.id
    WHERE
      question_likes.question_id = ?
    SQL
  end

  def self.num_likes_for_question_id(question_id)
    QuestionsDB.instance.execute(<<-SQL, question_id)
    SELECT
      COUNT(users)
    FROM
      users
    JOIN
      question_likes ON question_likes.user_id = users.id
    WHERE
      question_likes.question_id = ?
    SQL
  end

  def self.liked_questions_for_user_id(user_id)
    QuestionsDB.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      questions
    JOIN
      question_likes ON question_likes.question_id = questions.id
    WHERE
      question_likes.user_id = ?
    SQL
  end

  def self.most_liked_questions(n)
    QuestionsDB.instance.execute(<<-SQL, n)
    SELECT
      *, COUNT(questions)
    FROM
      questions
    JOIN
      question_likes ON question_likes.question_id = questions.id
    GROUP BY
      questions.id
    ORDER BY
      COUNT(question_likes.user_id) DESC
    LIMIT ?
    SQL
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
