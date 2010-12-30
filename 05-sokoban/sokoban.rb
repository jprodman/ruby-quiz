#!/usr/bin/env ruby

require 'matrix'
require 'trollop'

class Array
  def get2d(vec)
    self[vec[1]][vec[0]]
  end

  def set2d(vec, val)
    self[vec[1]][vec[0]] = val
  end

  def copy2d
    map {|a| a.dup}
  end

  def count2d(x)
    inject(0) { |sum, a| sum + a.count(x) }
  end
end

class Sokoban
  attr_reader :num_moves

  def initialize
    @symbols = {
      :floor => ' ',
      :man => '@',
      :crate => 'o',
      :wall => '#',
      :storage => '.',
      :crate_storage => '*',
      :man_storage => '+',
    }
    @level, @state = nil, nil
    @num_moves = 0
  end

  def load(input)
    level = nil
    if input
      level = input.split("\n").map do |line|
        line.chars.map { |c| @symbols.key(c) }
      end
    end
    if _validate(level)
      @level = level.copy2d
      restart
    end
  end

  def move(dir)
    vec = 
      case dir
      when :up
        Vector[0, -1]
      when :down
        Vector[0, 1]
      when :left
        Vector[-1, 0]
      when :right
        Vector[1, 0]
      end

    man_loc = locate_man
    new_loc = man_loc + vec
    case @state.get2d(new_loc)
    when :floor, :storage
      _move_man(man_loc, new_loc)
    when :crate, :crate_storage
      new_crate_loc = new_loc + vec
      case @state.get2d(new_crate_loc)
      when :floor
        @state.set2d(new_crate_loc, :crate)
        _move_man(man_loc, new_loc)
      when :storage
        @state.set2d(new_crate_loc, :crate_storage)
        _move_man(man_loc, new_loc)
      end
    end
  end

  def restart
    @state = @level.copy2d
    @num_moves = 0
  end

  def solved?
    @state.count2d(:crate) == 0
  end

  def locate_man
    y = @state.index { |line| line.index(:man) or line.index(:man_storage) }
    x = @state[y].index(:man)
    x ||= @state[y].index(:man_storage)

    Vector[x, y]
  end

  def to_s
    return '' unless @state
    qq = @state.map do |line|
      line.map { |spot| @symbols[spot] }.join + "\n"
    end
    qq.flatten.join
  end

  private
  def _move_man(from, to)
    case @state.get2d(to)
    when :floor, :crate
      @state.set2d(to, :man)
    when :storage, :crate_storage
      @state.set2d(to, :man_storage)
    end

    case @state.get2d(from)
    when :man
      @state.set2d(from, :floor)
    when :man_storage
      @state.set2d(from, :storage)
    end

    @num_moves += 1
  end

  def _validate(state)
    state and
      _validate_num_men(state) and
      _validate_num_packages(state)
  end

  def _validate_num_men(state)
    (state.flatten.count(:man) + state.flatten.count(:man_storage)) == 1
  end

  def _validate_num_packages(state)
    state.flatten.count(:crate) ==
      state.flatten.count(:storage) + 
      state.flatten.count(:man_storage)
  end
end

def read_char
  system "stty raw -echo"
  STDIN.getc
ensure
  system "stty -raw echo"
end

if __FILE__ == $0
  levels = File.readlines('sokoban_levels.txt')
  levels = levels.join('').split("\n\n")
  game = Sokoban.new()

  opts = Trollop::options do
    opt :start, "Start at level", :short => 's', :type => Integer
  end

  puts 'wasd to move, q to quit, r to restart'

  levels.each_index do |i|
    start = opts[:start] ? opts[:start] : 1
    next if i + 1 < start

    level = levels[i]
    game.load(level)

    if game.to_s == ''
      puts 'Invalid level' 
      break
    end

    puts "Level #{i+1} of #{levels.length}"
    puts game.to_s
    while !game.solved?
      case read_char
      when 'q' then Process.exit
      when 'w' then game.move(:up)
      when 'a' then game.move(:left)
      when 's' then game.move(:down)
      when 'd' then game.move(:right)
      when 'r' then game.restart()
      end
      puts game.to_s
      puts "Num moves: #{game.num_moves}"
    end
    puts "Well done! Solved Level #{i+1}!"
  end
end
