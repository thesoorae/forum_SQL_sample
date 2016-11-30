
class ModelBase
  # attr_accessor :title, :body, :user_id

  # def self.find_by_author_id(author_id)
  #   QuestionsDB.instance.execute(<<-SQL, author_id)
  #     SELECT
  #       *
  #     FROM
  #       questions
  #     WHERE
  #       user_id = ?
  #     SQL
  # end


  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM #{self::TABLE}")
    data.map { |datum| self.new(datum) }
  end

  def self.where(options)
    if options.is_a?(Hash)
      options = options.keys.map do |key|
        "#{key} = '#{options[key]}'"
      end
      options = options.join(" AND ")
    end

    QuestionsDB.instance.execute(<<-SQL)
    SELECT
    *
    FROM
    #{self::TABLE}
    WHERE
    #{options}
    SQL
  end

  def self.find_by_id(id)
    QuestionsDB.instance.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{self::TABLE}
    WHERE
      id = ?
    SQL
  end

  def self.method_missing(method_name, *args)
    method_name = method_name.to_s
    if method_name.start_with?('find_by_')
      attributes_string = method_name[('find_by_'.length)..-1]
      attributes_names = attributes_string.split('_and_')

      unless attributes_names.length == args.length
        raise 'inexpected # of args'
      end

      search_conditions = {}
      attributes_names.each_index do |i|
        search_conditions[attributes_names[i]] = args[i]
      end

      self.where(search_conditions)
    else
      super
    end
  end

  def create
    raise "#{self} already in database" if @id
    keys = create_hash.keys.join(", ")
    values = create_hash.values
    num = create_hash.length
    question_marks = "#{'?, '  * (num - 1)}?"
    QuestionsDB.instance.execute(<<-SQL, *values)
    INSERT INTO
      #{self.class::TABLE} (#{keys})
    VALUES
     (#{question_marks})
        SQL
    @id = QuestionsDB.instance.last_insert_row_id
  end

  def update
    raise "#{self} doesn't exist" unless @id
    variables = create_hash
    keys = variables.keys.join(" = ?, ") + " = ?"
    values = variables.values
    num = variables.length
    QuestionsDB.instance.execute(<<-SQL, *values, @id)
    UPDATE
      #{self.class::TABLE}
    SET
      #{keys}
    WHERE
      id = ?
    SQL
  end

  def save
    @id ? update : create
  end

def create_hash
  variables = {}
  self.instance_variables.each do |var|
    next if var == :@id
    new_var = var.to_s.delete("@").to_s
    variables[new_var] = self.send(new_var)
  end
  variables
end

end
