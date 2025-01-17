class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
             breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if @id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs
        (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE id = ? 
    SQL
    self.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
        SELECT id, name, breed
        FROM dogs
        WHERE name = ? AND breed = ?
    SQL
    result = DB[:conn].execute(sql, name, breed)[0]
    if !result
      self.create(name: name, breed: breed)
    else
      self.new_from_db(result)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
        SELECT id, name, breed
        FROM dogs
        WHERE name = ?
    SQL
    new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed= ?
        WHERE id = ?
    SQL
    DB[:conn].execute(sql, @name, @breed, @id)
    self
  end
end
