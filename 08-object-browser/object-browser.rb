#!/usr/bin/env ruby

require 'tree'

class ObjectTreeNode < Tree::TreeNode
  def initialize(name, content)
    super(name, content)
    case content
    when String, Numeric, NilClass, TrueClass, FalseClass, Time, Date, Range
      # Leaf node
    when Array
      content.each_with_index { |value, i| self.add(ObjectTreeNode.new(i, value)) }        
    when Hash
      content.each { |key, value| self.add(ObjectTreeNode.new(key, value)) }        
    when Struct
      # Todo
    else
      content.instance_variables.each { |key| self.add(ObjectTreeNode.new(key, content.instance_variable_get(key))) }
    end
  end

  def obj_to_s(ancestry_list = [])
    s = ancestry_list[0...-1].join
    s += (self.is_last_sibling? ? "+-" : "|-") unless ancestry_list.empty?
    s += has_children? ? "V" : ">"
    s += " #{name}: an #{content.class}" + (self.has_children? ? '' : ": #{content}") + "\n"

    ancestry_list[-1] = '  ' if self.is_last_sibling? and not ancestry_list.empty?
    s += children.map { |child|
      child.obj_to_s(ancestry_list + ['| '])
    }.join

    return s
  end

  def obj_print_tree
    puts self.obj_to_s
  end
end
