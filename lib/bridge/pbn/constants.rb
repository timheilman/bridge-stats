module Bridge
  module Pbn
    module ParserConstants
      ALLOWED_WHITESPACE_CHARS = /[ \t\v\r\n]/
      SEMICOLON = ';'
      CARRIAGE_RETURN = "\r"
      LINE_FEED = "\n"
      TAB = "\t"
      VERTICAL_TAB = "\v"
      SPACE = ' '
      OPEN_CURLY = '{'
      CLOSE_CURLY = '}'
      OPEN_BRACKET = '['
      # represents printable ASCII characters except: %;[]{}
      # note that " (\x22) *can* start a section, by starting a section element that is a string token
      SECTION_STARTING_CHARS = /[\x21-\x24\x26-\x3A\x3C-\x5A\x5C\x5E-\x7A\x7C\x7E]/
      ALLOWED_NAME_CHARS = /[A-Za-z0-9_]/
      DOUBLE_QUOTE = '"'
      CLOSE_BRACKET = ']'
      ORDINARY_SECTION_TOKEN_CHARS = /[^\]{\};%]/
      PLAY_SECTION_TAG_NAME = 'Play'
      AUCTION_SECTION_TAG_NAME = 'Auction'
      BACKSLASH = '\\'
    end

  end
end