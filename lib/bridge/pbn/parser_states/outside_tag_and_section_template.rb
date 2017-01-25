module Bridge
  module Pbn
    class OutsideTagAndSectionTemplate < PbnParserState
      require 'bridge/pbn/parser_states/constants'
      include Bridge::Pbn::ParserConstants
      include Bridge::Pbn::ParserState

      def process_char(char)
        case char
          when ALLOWED_WHITESPACE_CHARS
            return self
          when SEMICOLON
            return InSemicolonComment.new(parser, self)
          when OPEN_CURLY
            return InCurlyComment.new(parser, self)
          when OPEN_BRACKET
            perhaps_yield
            return BeforeTagName.new(parser)
          when SECTION_STARTING_TOKENS
            err_str = "Unexpected non-whitespace, non-semicolon, non-open brace, non-open bracket character: `#{char}'"
            parser.raise_error(err_str) unless section_tokens_allowed
            section_state = if parser.tag_name == PLAY_SECTION_TAG_NAME
                             InPlaySection.new(parser)
                           elsif parser.tag_name == AUCTION_SECTION_TAG_NAME
                             InAuctionSection.new(parser)
                           else
                             InSupplementalSection.new(parser)
                           end
            return section_state.process_char char
          else
            err_str = "Unexpected char outside 33-126 or closing brace, closing bracket, or percent sign: `#{char}'"
            parser.raise_error err_str
        end
      end

    end
  end
end