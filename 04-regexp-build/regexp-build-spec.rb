require '/Users/jpr/ruby-quiz/04-regexp-build/regexp-build.rb'

describe Regexp do
  describe 'build' do
    it 'should build a regexp for a single integer' do
      r = Regexp.build(32)
      r.should =~ '32'
      r.should =~ '435 32'
      r.should =~ '0040'
      r.should_not =~ '231'
      r.should_not =~ '3'
      r.should_not =~ '33321'
      r.should_not =~ '32qi'
    end
    it 'should build a regexp for a list of integers' do
      r = Regexp.build(321, 12, 66)
      r.should =~ '321'
      r.should =~ '12'
      r.should =~ '66'
      r.should_not =~ '9999'
    end
    it 'should build a regexp for a range' do
      r = Regexp.build(22..99, 234..123456)
      r.should =~ '66'
      r.should_not =~ '111'
      r.should_not =~ '233'
      r.should =~ '234'
      r.should =~ '999'
      r.should =~ '120000'
      r.should =~ '123456'
      r.should_not =~ '123457'
    end
    it 'should have a working "match" function' do
      r = Regexp.build(32)
      r.match('32').should == '32'
    end
  end
end
