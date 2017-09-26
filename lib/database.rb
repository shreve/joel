require 'sqlite3'

class Database
  @client = SQLite3::Database.new 'emails.db'

  class << self
    attr_accessor :client
  end

  def emails(limit: nil, sort: { uid: :asc })
    sql = 'select * from emails'
    sql << " order by #{sort.keys[0]} #{sort.values[0]}" unless sort.nil?
    sql << " limit #{limit}" unless limit.nil?
    self.class.client.execute(sql)
  end

  def emails=(emails)
    emails.each do |email|
      names = email.keys.join(',')
      placeholders = Array.new(email.keys.count).map { '?' }.join(',')
      sql = "insert into emails (#{names}) values (#{placeholders})"
      self.class.client.execute sql, email.values
    end
  end

  def mailboxes
    ['Inbox', 'Archived', 'Sent']
  end

  def self.migrate
    @client.execute <<-SQL
      create table if not exists emails (
        seqno int,
        uid int,
        subject varchar(500),
        sender varchar(200),
        date text
      );

      create table if not exists mailboxes (
        id int PRIMARY KEY,
        name varchar(100),
        full_name varchar(100),
        messages int,
        unread int
      )
    SQL
  end
end
