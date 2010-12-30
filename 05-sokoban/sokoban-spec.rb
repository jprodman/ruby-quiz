require '/Users/jpr/ruby-quiz/05-sokoban/sokoban.rb'

describe Array do
  before(:each) do
    @a = [[1,2],[3,4]]
  end

  describe '.get2d' do
    it 'should return the value at (x,y)' do
      @a.get2d(Vector[1,0]).should == 2
    end
  end

  describe '.set2d' do
    it 'should set the value at (x,y)' do
      @a.set2d(Vector[1,0],5)
      @a.should == [[1,5],[3,4]]
    end
  end

  describe '.copy2d' do
    it 'should create a deep copy of the array' do
      @a.copy2d.should == @a
    end
    it 'should not modify the original when the copy is modified' do
      copy = @a.copy2d
      copy.set2d(Vector[0,0],5)
      copy.should == [[5,2],[3,4]]
      @a.should == [[1,2],[3,4]]
    end
  end

  describe '.count2d' do
    it 'should count values in all sub-arrays' do
      @c = [[:crate, :crate], [:man, :crate], [:wall]]
      @c.count2d(:crate).should == 3
      @c.count2d('missing').should == 0
    end
  end
end

describe Sokoban do
  describe '.load' do
    it 'should load a level from a string' do
      level = <<LVL
#####
#.o@#
#####
LVL
      subject.load(level)
      subject.to_s.should == level
    end

    it 'should load a complex level from a string' do
      level = <<LVL
 ######
##*   ####
#.o o    #
#.o  +   #
##########
LVL
      subject.load(level)
      subject.to_s.should == level
    end

    it 'should not load an invalid level' do
      level = <<LVL
 ######
##    ####
#.o o    #
#    @   #
##########
LVL
      subject.load(level)
      subject.to_s.should == ''
    end
  end

  describe '.locate_man' do
    it 'should return a vector with the location of the man' do
      subject.load(<<LVL)
######
#.o@ #
######
LVL
      subject.locate_man.should == Vector[3,1]
    end

    context 'when the man is on storage' do
      it 'should return a vector with the location of the man' do
        subject.load(<<LVL)
 ######
##*   ####
#.o o    #
#.o  +   #
##########
LVL
        subject.locate_man.should == Vector[5,3]
      end
    end
  end

  describe '.move' do
    before(:all) do
      @level1 = <<LVL
######
#.o@ #
######
LVL
    end

    context 'when there is nothing in the way' do
      it 'should move the man' do
        subject.load(@level1)
        subject.move(:right)
        subject.to_s.should == <<LVL
######
#.o @#
######
LVL
      end
    end

    context 'when there is a crate in the way with nothing behind it' do
      it 'should move the man and push the crate' do
        subject.load(@level1)
        subject.move(:left)
        subject.to_s.should == <<LVL
######
#*@  #
######
LVL
      end
    end

    context 'when there is a wall in the way' do
      it 'should not move the man' do
        subject.load(@level1)
        subject.move(:up)
        subject.to_s.should == <<LVL
######
#.o@ #
######
LVL
      end
    end

    context 'when there is empty storage in the way' do
      it 'should move the man' do
        subject.load(<<LVL)
#####
#.@o#
#####
LVL
        subject.move(:left)
        subject.to_s.should == <<LVL
#####
#+ o#
#####
LVL
      end
    end

    context 'when there is a crate on storage in the way with nothing behind' do
      it 'should move the man and push the block' do
        subject.load(<<LVL)
#####
# *@#
#####
LVL
        subject.move(:left)
        subject.to_s.should == <<LVL
#####
#o+ #
#####
LVL
      end
    end

    context 'when there is a crate in the way with a wall it' do
      it 'should do nothing' do
        subject.load(<<LVL)
#####
#*@ #
#####
LVL
        subject.move(:left)
        subject.to_s.should == <<LVL
#####
#*@ #
#####
LVL
      end
    end

    context 'when there is a crate in the way with another crate it' do
      it 'should do nothing' do
        subject.load(<<LVL)
######
# **@#
######
LVL
        subject.move(:left)
        subject.to_s.should == <<LVL
######
# **@#
######
LVL
      end
    end
  end

  describe '.restart' do
    context 'when a move has been made and the game restarted' do
      it 'should return to the original state' do
        level = <<LVL
######
#.o@ #
######
LVL
        subject.load(level)
        subject.move(:left)
        subject.restart
        subject.to_s.should == level
      end
    end
  end
end
