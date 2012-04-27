require 'rspec'
require_relative './object-browser.rb'

describe ObjectTreeNode do
  describe '.obj_print_tree' do
    it 'should print the class and value for basic types' do
      ObjectTreeNode.new('string root', 'a friendly string').obj_to_s.should == <<HERE
> string root: an String: a friendly string
HERE
      ObjectTreeNode.new('float root', 44.55).obj_to_s.should == <<HERE
> float root: an Float: 44.55
HERE
      ObjectTreeNode.new('range root', 44..55).obj_to_s.should == <<HERE
> range root: an Range: 44..55
HERE
    end


    it 'should create and print subnodes for nested arrays and hashes' do
      c = [1,[1,2,3], {'ax' => [4,5], 'bx' => [['a','b'],[6,7]], 'cx' => 88, 'dx' => [3,4]},6,[1,2,3]]
      ObjectTreeNode.new('complex array root', c).obj_to_s.should == <<HERE
V complex array root: an Array
|-> 0: an Fixnum: 1
|-V 1: an Array
| |-> 0: an Fixnum: 1
| |-> 1: an Fixnum: 2
| +-> 2: an Fixnum: 3
|-V 2: an Hash
| |-V ax: an Array
| | |-> 0: an Fixnum: 4
| | +-> 1: an Fixnum: 5
| |-V bx: an Array
| | |-V 0: an Array
| | | |-> 0: an String: a
| | | +-> 1: an String: b
| | +-V 1: an Array
| |   |-> 0: an Fixnum: 6
| |   +-> 1: an Fixnum: 7
| |-> cx: an Fixnum: 88
| +-V dx: an Array
|   |-> 0: an Fixnum: 3
|   +-> 1: an Fixnum: 4
|-> 3: an Fixnum: 6
+-V 4: an Array
  |-> 0: an Fixnum: 1
  |-> 1: an Fixnum: 2
  +-> 2: an Fixnum: 3
HERE
    end


    it 'should print nested custom classes' do
      class TestA
        attr_reader :aNum, :aString, :aList, :aHash

        def initialize
          @aNum = 0
          @aString = 'foiled'
          @aList = [1,2,3]
          @aHash = { 1 => 'a', 2 => 'b' }
        end
      end

      class TestB
        attr_reader :num1, :A1, :Alist

        def initialize
          @num1 = 0
          @a1 = TestA.new
          @alist = [TestA.new, TestA.new]
        end
      end

      ObjectTreeNode.new('class root', TestB.new).obj_to_s.should == <<HERE
V class root: an TestB
|-> @num1: an Fixnum: 0
|-V @a1: an TestA
| |-> @aNum: an Fixnum: 0
| |-> @aString: an String: foiled
| |-V @aList: an Array
| | |-> 0: an Fixnum: 1
| | |-> 1: an Fixnum: 2
| | +-> 2: an Fixnum: 3
| +-V @aHash: an Hash
|   |-> 1: an String: a
|   +-> 2: an String: b
+-V @alist: an Array
  |-V 0: an TestA
  | |-> @aNum: an Fixnum: 0
  | |-> @aString: an String: foiled
  | |-V @aList: an Array
  | | |-> 0: an Fixnum: 1
  | | |-> 1: an Fixnum: 2
  | | +-> 2: an Fixnum: 3
  | +-V @aHash: an Hash
  |   |-> 1: an String: a
  |   +-> 2: an String: b
  +-V 1: an TestA
    |-> @aNum: an Fixnum: 0
    |-> @aString: an String: foiled
    |-V @aList: an Array
    | |-> 0: an Fixnum: 1
    | |-> 1: an Fixnum: 2
    | +-> 2: an Fixnum: 3
    +-V @aHash: an Hash
      |-> 1: an String: a
      +-> 2: an String: b
HERE
    end
  end
end
