require 'sqlite3'
require 'singleton'

class QuestionDBConnection < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end

class User
  attr_accessor :fname, :lname

  def self.all_users
    data = QuestionDBConnection.instance.execute(<<-SQL)
    SELECT
      *
    FROM
      users
    SQL

    data.map{ |datum| User.new(datum)}
  end

  def self.find_by_id(id)
    user = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionDBConnection.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL

    User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise "#{self} already exists" if @id

    QuestionDBConnection.instance.execute(<<-SQL, @fname, @lname)

    INSERT INTO
      users (fname, lname)
    VALUES
      (?, ?)
    SQL

    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def authored_questions
    Questions.find_by_author_id(@id)
  end

  def authored_replies
    Replies.find_by_user_id(@id)
  end


end

class Questions
  attr_accessor :fname, :lname

  def self.find_by_id(id)
    question = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

    Questions.new(question.first)
  end

  def self.find_by_author_id(author_id)
    questions_by_author = QuestionDBConnection.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        student_id = ?
    SQL

    questions_by_author.map { |question| Questions.new(question) }
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @student_id = options['student_id']
  end

  def author
    User.find_by_id(@student_id)
  end

  def replies
    Replies.find_by_question_id(@id)
  end


end

class Question_follows
  attr_accessor :questions_id, :student_id

  def self.find_by_id(id)
    question_pair = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL

    Question_follows.new(question_pair.first)
  end

  def self.followers_for_question_id(question_id)
    followers = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        users.id
      FROM
        users
      JOIN
        question_follows
      ON
        users.id = question_follows.student_id
      WHERE
        questions_id = ?
      SQL

    followers.map { |id| User.find_by_id(id['id']) }


  end

  def initialize(options)
    @id = options['id']
    @questions_id = options['questions_id']
    @student_id = options['student_id']
  end



end

class Replies

  attr_accessor :reply, :questions_id, :student_id, :parent_id

  def self.find_by_id(id)
    reply = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    Replies.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    replies = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        student_id = ?
    SQL

    replies.map{ |reply| Replies.new(reply) }
  end

  def self.find_by_question_id(question_id)
    reply = QuestionDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      *
    FROM
      replies
    WHERE
      questions_id = ?
    SQL

    reply.map {|datum| Replies.new(datum)}
  end

  def initialize(options)
    @id = options['id']
    @reply = options['reply']
    @questions_id = options['questions_id']
    @student_id = options['student_id']
    @parent_id = options['parent_id']
  end

  def author
    User.find_by_id(student_id)
  end

  def question
    Questions.find_by_id(@questions_id)
  end

  def parent_reply
    # parent = ''
    # begin
      parent = Replies.find_by_id(@parent_id)
    # rescue NoMethodError
    #   raise 'no parent for this comment' if parent.empty?
    # end

    parent
  end

  def child_replies
    # query_string = "SELECT reply FROM replies WHERE parent_id = @id"
    child_reply = QuestionDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        reply
      FROM
        replies
      WHERE
        parent_id = ?
      SQL

    child_reply.map { |child| Replies.new(child) }
  end

end

class Question_likes
  attr_accessor :questions_id, :student_id


  def self.find_by_id(id)
    liked = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    Question_likes.new(liked.first)
  end

  def initialize(options)
    @id = options['id']
    @questions_id = options['questions_id']
    @student_id = options['student_id']
  end

end
