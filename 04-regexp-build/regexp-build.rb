#!/usr/bin/env ruby

def Regexp.build(*args)
  ranges, numbers = args.partition{|arg| arg.class == Range}
  re = Regexp.new('.+')

  re.define_singleton_method(:match) { |str|
    nums = str.scan(/\b\d+\b/)
    nums.find { |str|
      num = Integer(str)
      numbers.member?(num) or ranges.any? { |rng| rng.member?(num) }
    }
  }

  re.define_singleton_method(:=~) { |str| !!self.match(str) }

  re
end

