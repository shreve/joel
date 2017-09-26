require 'mail'
require 'net/imap'
require 'json'

class EmailClient
  KEYS = {
    uid: 'UID',
    subject: 'BODY[HEADER.FIELDS (SUBJECT)]',
    sender: 'BODY[HEADER.FIELDS (FROM)]',
    date: 'INTERNALDATE'
  }.freeze

  def initialize
    @imap = Net::IMAP.new('imap.gmail.com', ssl: true)
    begin
      @imap.authenticate('PLAIN', ENV['USERNAME'], ENV['PASSWORD'])
      @imap.select('INBOX')
    rescue => e
      abort e
    end
  end

  def folders
    Thread.new do
      @folders ||= @imap.list('*', '*').map do |mailbox|
        next if mailbox.attr.include? :Haschildren
        mailbox.name #.split(mailbox.delim).last
        # attr = mailbox.attr.dup
        # attr.delete(:Hasnochildren)
        # attr.first || mailbox.name.to_sym
      end.compact
    end
  end

  def counts
    Thread.new do
      folders.value.map do |folder|
        [folder, @imap.status(folder.to_s, ['MESSAGES', 'UNSEEN'])]
      end.to_h
    end
  end

  def all
    Thread.new do
      emails = @imap.fetch(1..-1, KEYS.values)

      emails.map do |email|
        hash = { seqno: email.seqno }
        KEYS.each_pair do |human, imap|
          hash[human] = email.attr[imap]
        end
        hash[:seqno] = email.seqno
        hash
      end
    end
  end

  def clear
    @folders = nil
    @all = nil
  end
end
