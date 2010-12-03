#!/usr/bin/env ruby

def random_mapping(values, comparator = lambda { |a,b| false })
  covalues = values.shuffle
  mapping = Hash.new
  values.each { |val|
    covalues.each { |coval|
      unless (comparator.call(val, coval))
        mapping[val] = covalues.delete(coval)
        break
      end
    }
  }

  unless covalues.empty?
    covalues.each { |orphan|
      mapping.keys.shuffle.each { |key|
        value = mapping[key]
        unless (comparator.call(key, orphan) or comparator.call(value, orphan))
          mapping[orphan] = value
          mapping[key] = covalues.delete(orphan)
          break
        end
      }
    }
  end
  raise "Could not create a valid mapping" unless covalues.empty?

  return mapping
end

class Person
  include Comparable
  attr_reader :first, :last, :email
  def initialize(first, last, email)
    @first, @last, @email = first, last, email
  end
  def in_family(person)
    @last == person.last
  end
  def <=>(other)
    [@last, @first, @email] <=> [other.last, other.first, other.email]
  end
  def to_s()
    "\"#{@first} #{@last}\" <#{@email}>"
  end
end

class SecretSanta
  require 'rubygems'
  require 'tmail'
  require 'net/smtp'

  def randomize_santas(input)
    people = input.map { |person| Person.new(*person) }
    mapping = random_mapping(people, lambda { |a,b| a.in_family(b) })
  end

  def email_santas(targets)
    emails = targets.keys.map { |santa|
      email = TMail::Mail.new
      email.subject = "Your Secret Santa target"
      email.body = "#{targets[santa]}"
      # email.from = 'jprodman@gmail.com'
      # email['to'] = "#{santa}"
      # email['date'] = Time.now
      email
    }

    return emails
    # Net::SMTP.start( 'localhost', 25 ) do|smtpclient|
    #   emails.each do |email|
    #     smtpclient.send_message(
    #       email.to_s,
    #       email.from,
    #       email.to
    #     )
    #   end
    # end
  end
end

if __FILE__ == $0
  persons = []
  ARGV.each do |arg|
    persons += [Person(*arg.split)]
  end
  secret = SecretSanta.new
  santa_targets = secret.randomize_santas(arg)
  puts secret.email_santas(santa_targets)
end
