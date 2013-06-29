module RubyLint
  module Analysis
    ##
    # The UnusedVariables class checks for variables that are defined but never
    # used. Whenever it finds one of these variables it will add a
    # corresponding warning message.
    #
    class UnusedVariables < Base
      ##
      # Hash containing the various variable types for which to add warnings
      # and human readable names for these types.
      #
      # @return [Hash]
      #
      VARIABLE_TYPES = {
        :lvasgn => 'local variable',
        :gvasgn => 'global variable',
        :ivasgn => 'instance variable',
        :cvasgn => 'class variable'
      }

      VARIABLE_TYPES.each do |type, label|
        define_method("on_#{type}") do |node|
          type     = VirtualMachine::ASSIGNMENT_TYPES[node.type]
          name     = node.name
          variable = current_scope.lookup(type, name)

          if variable and !variable.used?
            warning("unused #{label} #{name}", node)
          end
        end
      end

      ##
      # Handles regular constants as well as constant paths.
      #
      # @param [RubyLint::AST::Node] node
      #
      def on_casgn(node)
        variable = resolve_constant_path(node)
        name     = constant_segments(node).join('::')

        if variable and !variable.used?
          warning("unused constant #{name}", node)
        end
      end
    end # UnusedVariables
  end # Analysis
end # RubyLint
