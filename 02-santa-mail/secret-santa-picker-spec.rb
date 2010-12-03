require '/Users/jpr/ruby-quiz/02-santa-mail/secret-santa-picker.rb'

describe 'random_mapping' do
  it 'should create a 1 to 1  mapping' do
    mapping = random_mapping(['JP', 'Bi', 'Gm',])
    
    mapping.keys.sort.should == ['Bi', 'Gm', 'JP']
    mapping.values.sort.should == ['Bi', 'Gm', 'JP']
  end

  it 'should not allow "equivalent" items to point to each other when given a comparator function' do
    mapping = random_mapping(
      ['JP', 'JK', 'Bi', 'Gm',],
      lambda { |a,b| a[0] == b[0] }
    )

    mapping.keys.sort.should == ['Bi', 'Gm', 'JK', 'JP']
    mapping.values.sort.should == ['Bi', 'Gm', 'JK', 'JP']
    mapping['JP'].should_not == 'JP'
    mapping['JP'].should_not == 'JK'
    mapping['JK'].should_not == 'JP'
    mapping['JK'].should_not == 'JK'
    mapping['Bi'].should_not == 'Bi'
    mapping['Gm'].should_not == 'Gm'
  end

  it 'should raise an error for less than two items' do
    lambda { random_mapping(
      ['JP',],
      lambda { |a,b| a == b }
    ) }.should raise_error(RuntimeError, "Could not create a valid mapping")
  end

  it "should return an empty hash if a mapping isn't possible" do
    lambda { random_mapping(
      ['JP', 'JK', 'Gm',],
      lambda { |a,b| a[0] == b[0] }
    ) }.should raise_error(RuntimeError, "Could not create a valid mapping")
  end
end

describe Person do
  describe 'initializion' do
    it 'should fill in first, last, email with inialization params' do
      person = Person.new('bob', 'gig', 'com')
      person.first().should == 'bob'
      person.last().should == 'gig'
      person.email().should == 'com'
    end
  end

  describe 'comparator' do
    it 'should return true for equal items' do
      person1 = Person.new('bob', 'gig', 'com')
      person2 = Person.new('bob', 'gig', 'com')
      person1.should == person2
    end

    it 'should return false for unequal items' do
      person1 = Person.new('bob', 'gig', 'com')
      person2 = Person.new('joe', 'gig', 'com')
      person1.should_not == person2
    end
  end

  describe '.in_family' do
    it 'should return true for family members' do
      person1 = Person.new('bob', 'gig', 'com')
      person2 = Person.new('sal', 'gig', 'gov')
      person1.in_family(person2).should == true
    end

    it 'should not return true for non-family members' do
      person1 = Person.new('bob', 'gig', 'com')

      person2 = Person.new('bob', 'lost', 'com')
      person1.in_family(person2).should == false
    end
  end

  describe '.to_s' do
    it 'should return a properly formatted email string' do
      Person.new('Bob', 'Gig', 'bob@gig.com').to_s().should == '"Bob Gig" <bob@gig.com>'
    end
  end
end

class MockSMTP
  def send_message(msg, from, to)
  end
end

describe SecretSanta do
  before(:each) do
    @mock_smtp = MockSMTP.new
    Net::SMTP.stub(:start).with('localhost', 25).and_return(@mock_smtp)
  end

  describe '.randomize_santas' do
    it 'should give each person a santa not in their family' do
      mapping = subject.randomize_santas([
        ['JP', 'Rodman', 'b#y.z'],
        ['Bill', 'Rodman', 'b#y.z'],
        ['Gim', 'Li', 'g#y.z'],
        ['Jed', 'Li', 'g#y.z'],
      ])

      mapping.keys.sort.should == [
        Person.new('Gim', 'Li', 'g#y.z'),
        Person.new('Jed', 'Li', 'g#y.z'),
        Person.new('Bill', 'Rodman', 'b#y.z'),
        Person.new('JP', 'Rodman', 'b#y.z'),
      ]
      mapping.values.sort.should == [
        Person.new('Gim', 'Li', 'g#y.z'),
        Person.new('Jed', 'Li', 'g#y.z'),
        Person.new('Bill', 'Rodman', 'b#y.z'),
        Person.new('JP', 'Rodman', 'b#y.z'),
      ]
      mapping[
        Person.new('Bill', 'Rodman', 'b#y.z')
      ].should_not == Person.new('JP', 'Rodman', 'b#y.z')
      mapping[
        Person.new('JP', 'Rodman', 'b#y.z')
      ].should_not == Person.new('Bill', 'Rodman', 'b#y.z')
      mapping[
        Person.new('Gim', 'Li', 'g#y.z')
      ].should_not == Person.new('Jed', 'Li', 'g#y.z')
      mapping[
        Person.new('Jed', 'Li', 'g#y.z')
      ].should_not == Person.new('Gim', 'Li', 'g#y.z')
    end
  end 

  describe '.email_santas' do
    it 'should email each secret santa their target' do
      # @mock_smtp.should_receive(:send_message)
      # @mock_smtp.should_receive(:send_message)

      mails = subject.email_santas(subject.randomize_santas([
        ['Gim', 'Li', 'g#y.z'],
        ['Jet', 'Lee', 'j#y.z'],
      ])).map { |mail| "#{mail}" }

      mails.should include(
'Subject: Your Secret Santa target

"Jet Lee" <j#y.z>',
      )
      mails.should include(
'Subject: Your Secret Santa target

"Gim Li" <g#y.z>'
      )
    end
  end
end
