module Apricot
  # A linked list implementation representing (a b c) syntax in Apricot
  class List
    include Enumerable

    def self.[](*args)
      list = EmptyList
      args.reverse_each do |arg|
        list = list.cons(arg)
      end
      list
    end

    attr_reader :head, :tail

    def initialize(head, tail)
      @head = head
      @tail = tail
    end

    def cons(x)
      List.new(x, self)
    end

    def each
      list = self
      until list.empty?
        yield list.head
        list = list.tail
      end
    end

    def ==(other)
      return false unless other.is_a? List

      list = self

      until list.empty?
        return false if other.empty? || list.head != other.head

        list = list.tail
        other = other.tail
      end

      other.empty?
    end

    alias_method :eql?, :==

    def hash
      hashes = map {|x| x.hash }
      hashes.reduce(hashes.size) {|acc,hash| acc ^ hash }
    end

    def empty?
      !@tail
    end

    def initialize_copy(other)
      super
      @tail = other.tail.dup if other.tail && !other.tail.empty?
    end

    private :initialize_copy

    def inspect
      return '()' if empty?

      str = '('
      each {|x| str << x.apricot_inspect << ' ' }
      str.chop!
      str << ')'
    end

    alias_method :to_s, :inspect

    EmptyList = new(nil, nil)
  end
end
