module Bridge
  module Pbn
    class BeforeTagClose < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserDelegate
      def process_chars
        case parser.cur_char
          when ALLOWED_WHITESPACE_CHARS
            parser.inc_char
          when CLOSE_BRACKET
            parser.state = :outOfTag
            parser.inc_char
          else
            parser.raise_exception
        end
      end
    end
  end
end