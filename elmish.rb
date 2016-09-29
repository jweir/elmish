module Elmish
  def Actions(n)
    n.each_with_index do |term, _index|
      name, type = term.split(/\//)

      if type
        action = const_set name, Class.new(Union)
        action.type = Object.const_get(type)
        define_singleton_method(name) do |value = nil|
          action.new << value
        end
      else
        action = const_set name, Class.new(Type) # (Type.new [self.name, name].join("::"))
      end
    end
  end

  class Type
    def self.===(o)
      self == o
    end

    def self.to_s
      "(#{name})"
    end
  end

  class Union
    class TypeMismatch < RuntimeError; end

    class << self
      # this is cheap
      attr_accessor :type
    end

    attr_reader :value

    def <<(value)
      raise TypeMismatch, [value.class, self.class.type] unless value.is_a?(self.class.type)
      @value = value
      self
    end

    def self.to_s
      "(#{name})"
    end

    def to_s
      s = [self.class.name, @value].compact.join(' : ')
      "(#{s})"
    end
  end
end
