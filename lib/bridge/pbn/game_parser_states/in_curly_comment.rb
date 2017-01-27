module Bridge
  module Pbn
    class InCurlyComment
      require 'bridge/pbn/game_parser_states/game_parser_state'
      include Bridge::Pbn::GameParserState

      def post_initialize
        @comment = ''
      end

      def process_char(char)
        case char
          when CLOSE_CURLY
            next_state.add_comment(@comment)
            return next_state
          else
            @comment << char
            return self
        end
      end

      def finalize
        parser.raise_error 'end of input within unclosed brace comment'
      end
    end
  end
end