# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `dotenv` gem.
# Please instead update this file by running `bin/tapioca gem dotenv`.

# The top level Dotenv module. The entrypoint for the application logic.
#
# source://dotenv//lib/dotenv/substitutions/variable.rb#3
module Dotenv
  private

  # source://dotenv//lib/dotenv.rb#82
  def ignoring_nonexistent_files; end

  # source://dotenv//lib/dotenv.rb#68
  def instrument(name, payload = T.unsafe(nil), &block); end

  # source://dotenv//lib/dotenv.rb#13
  def load(*filenames); end

  # same as `load`, but raises Errno::ENOENT if any files don't exist
  #
  # source://dotenv//lib/dotenv.rb#23
  def load!(*filenames); end

  # same as `load`, but will override existing values in `ENV`
  #
  # source://dotenv//lib/dotenv.rb#31
  def overload(*filenames); end

  # same as `overload`, but raises Errno::ENOENT if any files don't exist
  #
  # source://dotenv//lib/dotenv.rb#41
  def overload!(*filenames); end

  # returns a hash of parsed key/value pairs but does not modify ENV
  #
  # source://dotenv//lib/dotenv.rb#49
  def parse(*filenames); end

  # source://dotenv//lib/dotenv.rb#76
  def require_keys(*keys); end

  # Internal: Helper to expand list of filenames.
  #
  # Returns a hash of all the loaded environment variables.
  #
  # source://dotenv//lib/dotenv.rb#60
  def with(*filenames); end

  class << self
    # source://dotenv//lib/dotenv.rb#82
    def ignoring_nonexistent_files; end

    # source://dotenv//lib/dotenv.rb#68
    def instrument(name, payload = T.unsafe(nil), &block); end

    # Returns the value of attribute instrumenter.
    #
    # source://dotenv//lib/dotenv.rb#8
    def instrumenter; end

    # Sets the attribute instrumenter
    #
    # @param value the value to set the attribute instrumenter to.
    #
    # source://dotenv//lib/dotenv.rb#8
    def instrumenter=(_arg0); end

    # source://dotenv//lib/dotenv.rb#13
    def load(*filenames); end

    # same as `load`, but raises Errno::ENOENT if any files don't exist
    #
    # source://dotenv//lib/dotenv.rb#23
    def load!(*filenames); end

    # same as `load`, but will override existing values in `ENV`
    #
    # source://dotenv//lib/dotenv.rb#31
    def overload(*filenames); end

    # same as `overload`, but raises Errno::ENOENT if any files don't exist
    #
    # source://dotenv//lib/dotenv.rb#41
    def overload!(*filenames); end

    # returns a hash of parsed key/value pairs but does not modify ENV
    #
    # source://dotenv//lib/dotenv.rb#49
    def parse(*filenames); end

    # @raise [MissingKeys]
    #
    # source://dotenv//lib/dotenv.rb#76
    def require_keys(*keys); end

    # Internal: Helper to expand list of filenames.
    #
    # Returns a hash of all the loaded environment variables.
    #
    # source://dotenv//lib/dotenv.rb#60
    def with(*filenames); end
  end
end

# This class inherits from Hash and represents the environment into which
# Dotenv will load key value pairs from a file.
#
# source://dotenv//lib/dotenv/environment.rb#4
class Dotenv::Environment < ::Hash
  # @return [Environment] a new instance of Environment
  #
  # source://dotenv//lib/dotenv/environment.rb#7
  def initialize(filename, is_load = T.unsafe(nil)); end

  # source://dotenv//lib/dotenv/environment.rb#20
  def apply; end

  # source://dotenv//lib/dotenv/environment.rb#24
  def apply!; end

  # Returns the value of attribute filename.
  #
  # source://dotenv//lib/dotenv/environment.rb#5
  def filename; end

  # source://dotenv//lib/dotenv/environment.rb#12
  def load(is_load = T.unsafe(nil)); end

  # source://dotenv//lib/dotenv/environment.rb#16
  def read; end
end

# source://dotenv//lib/dotenv/missing_keys.rb#2
class Dotenv::Error < ::StandardError; end

# source://dotenv//lib/dotenv/parser.rb#5
class Dotenv::FormatError < ::SyntaxError; end

# source://dotenv//lib/dotenv/missing_keys.rb#4
class Dotenv::MissingKeys < ::Dotenv::Error
  # @return [MissingKeys] a new instance of MissingKeys
  #
  # source://dotenv//lib/dotenv/missing_keys.rb#5
  def initialize(keys); end
end

# This class enables parsing of a string for key value pairs to be returned
# and stored in the Environment. It allows for variable substitutions and
# exporting of variables.
#
# source://dotenv//lib/dotenv/parser.rb#10
class Dotenv::Parser
  # @return [Parser] a new instance of Parser
  #
  # source://dotenv//lib/dotenv/parser.rb#40
  def initialize(string, is_load = T.unsafe(nil)); end

  # source://dotenv//lib/dotenv/parser.rb#46
  def call; end

  private

  # source://dotenv//lib/dotenv/parser.rb#82
  def expand_newlines(value); end

  # source://dotenv//lib/dotenv/parser.rb#62
  def parse_line(line); end

  # source://dotenv//lib/dotenv/parser.rb#70
  def parse_value(value); end

  # source://dotenv//lib/dotenv/parser.rb#100
  def perform_substitutions(value, maybe_quote); end

  # source://dotenv//lib/dotenv/parser.rb#78
  def unescape_characters(value); end

  # source://dotenv//lib/dotenv/parser.rb#90
  def unescape_value(value, maybe_quote); end

  # @return [Boolean]
  #
  # source://dotenv//lib/dotenv/parser.rb#86
  def variable_not_set?(line); end

  class << self
    # source://dotenv//lib/dotenv/parser.rb#35
    def call(string, is_load = T.unsafe(nil)); end

    # Returns the value of attribute substitutions.
    #
    # source://dotenv//lib/dotenv/parser.rb#33
    def substitutions; end
  end
end

# source://dotenv//lib/dotenv/parser.rb#14
Dotenv::Parser::LINE = T.let(T.unsafe(nil), Regexp)

# source://dotenv//lib/dotenv/substitutions/variable.rb#4
module Dotenv::Substitutions; end

# Substitute shell commands in a value.
#
#   SHA=$(git rev-parse HEAD)
#
# source://dotenv//lib/dotenv/substitutions/command.rb#9
module Dotenv::Substitutions::Command
  class << self
    # source://dotenv//lib/dotenv/substitutions/command.rb#23
    def call(value, _env, _is_load); end
  end
end

# Substitute variables in a value.
#
#   HOST=example.com
#   URL="https://$HOST"
#
# source://dotenv//lib/dotenv/substitutions/variable.rb#10
module Dotenv::Substitutions::Variable
  class << self
    # source://dotenv//lib/dotenv/substitutions/variable.rb#21
    def call(value, env, is_load); end

    private

    # source://dotenv//lib/dotenv/substitutions/variable.rb#31
    def substitute(match, variable, env); end
  end
end
