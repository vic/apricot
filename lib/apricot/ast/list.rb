module Apricot::AST
  class List < Node
    attr_reader :elements

    def initialize(line, elements)
      super(line)
      @elements = elements
    end

    def bytecode(g)
      pos(g)

      if @elements.empty?
        quote_bytecode(g)
      else
        callee = @elements.first
        args = @elements[1..-1]

        if callee.is_a?(Identifier)
          name = callee.name

          # Handle special forms such as def, let, fn, quote, etc
          if special = Apricot::SpecialForm[name]
            special.bytecode(g, args)
            return

          # Handle send special forms like (.foo), (Foo.) (Foo/bar)
          elsif callee.is_a?(Send)
            args.insert(0, callee.receiver) if callee.receiver
            method = Identifier.new(callee.line, callee.message)
            args.insert(1, method)
            Apricot::SpecialForm[:'.'].bytecode(g, args)
            return
          end

        end

        # TODO: macros
        callee.bytecode(g)
        args.each {|arg| arg.bytecode(g) }
        g.send :apricot_call, args.length
      end
    end

    def quote_bytecode(g)
      g.push_cpath_top
      g.find_const :Apricot
      g.find_const :List

      if @elements.empty?
        g.find_const :EmptyList
      else
        @elements.each {|e| e.quote_bytecode(g) }
        g.send :[], @elements.length
      end
    end

    def node_equal?(other)
      self.elements == other.elements
    end

    def [](*i)
      @elements[*i]
    end
  end
end
