#!/usr/bin/env ruby

def find_closest(target, values)
  return values.min { |a,b| (a - target).abs <=> (b - target).abs }
end

def squish_numbers_into_target(target, sources)
  ops = {
    '*' => lambda { |a,b| a * b },
    '+' => lambda { |a,b| a + b },
    '-' => lambda { |a,b| a - b },
    '/' => lambda { |a,b| a / b },
  }
  calcs = {}
  avail = sources.sort

  avail.each { |x|
    new_avail = avail.dup
    new_avail.delete_at(new_avail.index(x))
    calcs[x] ||= []
    calcs[x].push({ :calc => [x], :avail => new_avail })
  }

  closest = find_closest(target, avail)
  closest_calc = calcs[closest][0][:calc]

  while calcs.length > 0
    break if closest == target

    next_num = find_closest(target, calcs.keys)    
    # calcs.each { |c| puts "#{c[0]} -- #{c[1]}" }
    # puts closest
    # puts next_num

    next_val = calcs[next_num][0]

    if find_closest(target, [closest, next_num]) == next_num
      closest = next_num
      closest_calc = next_val[:calc]
    end

    if next_val[:avail].length > 0
      operand = next_val[:avail].pop
      ops.keys.each { |op|
        result = ops[op].call(next_num, operand)
        calc = [ op, next_val[:calc], operand].flatten
        avail = next_val[:avail].dup
        calcs[result] ||= []
        calcs[result].push({ :calc => calc, :avail => avail })
      }
    end

    calcs[next_num].shift if calcs[next_num][0][:avail].length == 0
    calcs.delete(next_num) if calcs[next_num].length == 0
  end

  return closest, closest_calc
end

def formula_to_s(formula)
  if formula.is_a? Array and formula.length >= 1
    if formula[0].is_a? Integer
      return [formula[0], formula[1..-1]]
    elsif formula.length >= 3
      op = formula[0]
      x = formula[1..-1]
      a, b = formula_to_s(x)
      b, c = formula_to_s(b)
      return "(#{a} #{formula[0]} #{b})", c
    end
  end
  return '', []
end

if __FILE__ == $0
  human_readable = ARGV[0] == '-h'
  ARGV.shift if human_readable
  target = Integer(ARGV[0])
  sources = ARGV[1..-1].map { |a| Integer(a) }
  result, calc = squish_numbers_into_target(target, sources)
  if human_readable
    puts "#{formula_to_s(calc)[0]} = #{result}"
  else
    puts [result, calc]
  end
end
