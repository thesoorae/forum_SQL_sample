require_relative 'question.rb'
require_relative 'modelbase.rb'

class Follow < ModelBase
  attr_accessor :user_id, :question_id

  TABLE = 'question_follows'

  def self.most_followed_questions(n)
    QuestionsDB.instance.execute(<<-SQL, n)
  SELECT
    *, COUNT(question_follows.user_id)
  FROM
    questions
  JOIN
    question_follows ON questions.id = question_follows.question_id
  GROUP BY
    questions.id
  ORDER BY
    COUNT(question_follows.user_id) DESC
  LIMIT
    ?
  SQL
  end



  def self.followers_for_question_id(question_id)
    QuestionsDB.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      users
    JOIN
      question_follows ON question_follows.user_id = users.id
    WHERE
      question_follows.question_id = ?
    SQL
  end

  def self.followed_questions_for_user_id(user_id)
    QuestionsDB.instance.execute(<<-SQL, user_id)
    SELECT
      questions.*
    FROM
      questions
    JOIN
      question_follows ON question_follows.question_id = questions.id
    WHERE
      question_follows.user_id = ?
    SQL
  end

  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  # def create
  #   raise "question doesn\'t exist" unless @question_id
  #   raise "user doesn\'t exist" unless @user_id
  #
  #   QuestionsDB.instance.execute(<<-SQL, @user_id, @question_id)
  #   INSERT INTO
  #     question_follows (user_id, question_id)
  #   VALUES
  #     (?, ?)
  #   SQL
  # end

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
