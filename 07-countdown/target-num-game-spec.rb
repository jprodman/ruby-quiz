require '/Users/jpr/ruby-quiz/07-countdown/target-num-game.rb'

describe 'find_closest' do
  it 'should find the closest number in a list to a target number' do
    find_closest(5, [2,5,6,25]).should == 5
    find_closest(5, [2,25,4]).should == 4
    find_closest(25, [2,5,6]).should == 6
    find_closest(-1, [25,6,2,5,25]).should == 2
  end
end

describe 'squish_numbers_into_target' do
  it 'should return the target if it is one of the sources' do
    squish_numbers_into_target(5, [2,5,6,25]).should == [5, [5]]
  end
  it 'should return rpn for a set of operations on the sources whose result is closest to the target' do
    squish_numbers_into_target(5, [2,7]).should == [5, ['-',7,2]]
  end
  it 'should work for harder problems' do
    squish_numbers_into_target(44, [1,2,5,7]).should == [44, ['-','*','+',2,7,5,1]]
  end
  it 'should find nonlinear orders of operations' do
    squish_numbers_into_target(11, [55,3,2]).should == [44, ['/',55,'+',2,3]]
  end
end
