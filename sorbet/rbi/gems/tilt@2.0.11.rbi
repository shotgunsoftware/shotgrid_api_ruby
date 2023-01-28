# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `tilt` gem.
# Please instead update this file by running `bin/tapioca gem tilt`.

# Namespace for Tilt. This module is not intended to be included anywhere.
#
# source://tilt//lib/tilt/mapping.rb#3
module Tilt
  class << self
    # @see Tilt::Mapping#[]
    #
    # source://tilt//lib/tilt.rb#47
    def [](file); end

    # @example
    #   tmpl = Tilt['index.erb'].new { '<%= Tilt.current_template %>' }
    #   tmpl.render == tmpl.to_s
    # @note This is currently an experimental feature and might return nil
    #   in the future.
    # @return the template object that is currently rendering.
    #
    # source://tilt//lib/tilt.rb#69
    def current_template; end

    # @return [Tilt::Mapping] the main mapping object
    #
    # source://tilt//lib/tilt.rb#12
    def default_mapping; end

    # @private
    #
    # source://tilt//lib/tilt.rb#17
    def lazy_map; end

    # @see Tilt::Mapping#new
    #
    # source://tilt//lib/tilt.rb#42
    def new(file, line = T.unsafe(nil), options = T.unsafe(nil), &block); end

    # @deprecated Use {register} instead.
    #
    # source://tilt//lib/tilt.rb#32
    def prefer(template_class, *extensions); end

    # @see Tilt::Mapping#register
    #
    # source://tilt//lib/tilt.rb#22
    def register(template_class, *extensions); end

    # @see Tilt::Mapping#register_lazy
    #
    # source://tilt//lib/tilt.rb#27
    def register_lazy(class_name, file, *extensions); end

    # @return [Boolean]
    # @see Tilt::Mapping#registered?
    #
    # source://tilt//lib/tilt.rb#37
    def registered?(ext); end

    # @see Tilt::Mapping#template_for
    #
    # source://tilt//lib/tilt.rb#52
    def template_for(file); end

    # @see Tilt::Mapping#templates_for
    #
    # source://tilt//lib/tilt.rb#57
    def templates_for(file); end
  end
end

# CSV Template implementation. See:
# http://ruby-doc.org/stdlib/libdoc/csv/rdoc/CSV.html
#
# == Example
#
#    # Example of csv template
#    tpl = <<-EOS
#      # header
#      csv << ['NAME', 'ID']
#
#      # data rows
#      @people.each do |person|
#        csv << [person[:name], person[:id]]
#      end
#    EOS
#
#    @people = [
#      {:name => "Joshua Peek", :id => 1},
#      {:name => "Ryan Tomayko", :id => 2},
#      {:name => "Simone Carletti", :id => 3}
#    ]
#
#    template = Tilt::CSVTemplate.new { tpl }
#    template.render(self)
#
# source://tilt//lib/tilt/csv.rb#36
class Tilt::CSVTemplate < ::Tilt::Template
  # source://tilt//lib/tilt/csv.rb#59
  def precompiled(locals); end

  # source://tilt//lib/tilt/csv.rb#51
  def precompiled_template(locals); end

  # source://tilt//lib/tilt/csv.rb#47
  def prepare; end

  class << self
    # source://tilt//lib/tilt/csv.rb#39
    def engine; end
  end
end

# Extremely simple template cache implementation. Calling applications
# create a Tilt::Cache instance and use #fetch with any set of hashable
# arguments (such as those to Tilt.new):
#
#     cache = Tilt::Cache.new
#     cache.fetch(path, line, options) { Tilt.new(path, line, options) }
#
# Subsequent invocations return the already loaded template object.
#
# @note Tilt::Cache is a thin wrapper around Hash.  It has the following
#   limitations:
#   * Not thread-safe.
#   * Size is unbounded.
#   * Keys are not copied defensively, and should not be modified after
#   being passed to #fetch.  More specifically, the values returned by
#   key#hash and key#eql? should not change.
#   If this is too limiting for you, use a different cache implementation.
#
# source://tilt//lib/tilt.rb#91
class Tilt::Cache
  # @return [Cache] a new instance of Cache
  #
  # source://tilt//lib/tilt.rb#92
  def initialize; end

  # Clears the cache.
  #
  # source://tilt//lib/tilt.rb#109
  def clear; end

  # Caches a value for key, or returns the previously cached value.
  # If a value has been previously cached for key then it is
  # returned. Otherwise, block is yielded to and its return value
  # which may be nil, is cached under key and returned.
  #
  # @yield
  # @yieldreturn the value to cache for key
  #
  # source://tilt//lib/tilt.rb#102
  def fetch(*key); end
end

# source://tilt//lib/tilt/template.rb#7
module Tilt::CompiledTemplates; end

# Used for detecting autoloading bug in JRuby
#
# source://tilt//lib/tilt/dummy.rb#2
class Tilt::Dummy; end

# ERB template implementation. See:
# http://www.ruby-doc.org/stdlib/libdoc/erb/rdoc/classes/ERB.html
#
# source://tilt//lib/tilt/erb.rb#7
class Tilt::ERBTemplate < ::Tilt::Template
  # source://tilt//lib/tilt/erb.rb#56
  def precompiled(locals); end

  # source://tilt//lib/tilt/erb.rb#44
  def precompiled_postamble(locals); end

  # source://tilt//lib/tilt/erb.rb#36
  def precompiled_preamble(locals); end

  # source://tilt//lib/tilt/erb.rb#31
  def precompiled_template(locals); end

  # source://tilt//lib/tilt/erb.rb#21
  def prepare; end

  class << self
    # source://tilt//lib/tilt/erb.rb#12
    def default_output_variable; end

    # source://tilt//lib/tilt/erb.rb#16
    def default_output_variable=(name); end
  end
end

# source://tilt//lib/tilt/erb.rb#10
Tilt::ERBTemplate::SUPPORTS_KVARGS = T.let(T.unsafe(nil), Array)

# source://tilt//lib/tilt/etanni.rb#4
class Tilt::EtanniTemplate < ::Tilt::Template
  # source://tilt//lib/tilt/etanni.rb#22
  def precompiled(locals); end

  # source://tilt//lib/tilt/etanni.rb#18
  def precompiled_template(locals); end

  # source://tilt//lib/tilt/etanni.rb#5
  def prepare; end
end

# Haml template implementation. See:
# http://haml.hamptoncatlin.com/
#
# source://tilt//lib/tilt/haml.rb#7
class Tilt::HamlTemplate < ::Tilt::Template
  # @raise [ArgumentError]
  #
  # source://tilt//lib/tilt/haml.rb#22
  def evaluate(scope, locals, &block); end

  # Precompiled Haml source. Taken from the precompiled_with_ambles
  # method in Haml::Precompiler:
  # http://github.com/nex3/haml/blob/master/lib/haml/precompiler.rb#L111-126
  #
  # source://tilt//lib/tilt/haml.rb#27
  def precompiled_template(locals); end

  # Following definitions are for Haml <= 4 and deprecated.
  #
  # source://tilt//lib/tilt/haml.rb#12
  def prepare; end
end

# Kramdown Markdown implementation. See:
# http://kramdown.rubyforge.org/
#
# source://tilt//lib/tilt/kramdown.rb#7
class Tilt::KramdownTemplate < ::Tilt::Template
  # @return [Boolean]
  #
  # source://tilt//lib/tilt/kramdown.rb#20
  def allows_script?; end

  # source://tilt//lib/tilt/kramdown.rb#16
  def evaluate(scope, locals, &block); end

  # source://tilt//lib/tilt/kramdown.rb#10
  def prepare; end
end

# source://tilt//lib/tilt/kramdown.rb#8
Tilt::KramdownTemplate::DUMB_QUOTES = T.let(T.unsafe(nil), Array)

# @private
#
# source://tilt//lib/tilt/template.rb#16
Tilt::LOCK = T.let(T.unsafe(nil), Thread::Mutex)

# Tilt::Mapping associates file extensions with template implementations.
#
#     mapping = Tilt::Mapping.new
#     mapping.register(Tilt::RDocTemplate, 'rdoc')
#     mapping['index.rdoc'] # => Tilt::RDocTemplate
#     mapping.new('index.rdoc').render
#
# You can use {#register} to register a template class by file
# extension, {#registered?} to see if a file extension is mapped,
# {#[]} to lookup template classes, and {#new} to instantiate template
# objects.
#
# Mapping also supports *lazy* template implementations. Note that regularly
# registered template implementations *always* have preference over lazily
# registered template implementations. You should use {#register} if you
# depend on a specific template implementation and {#register_lazy} if there
# are multiple alternatives.
#
#     mapping = Tilt::Mapping.new
#     mapping.register_lazy('RDiscount::Template', 'rdiscount/template', 'md')
#     mapping['index.md']
#     # => RDiscount::Template
#
# {#register_lazy} takes a class name, a filename, and a list of file
# extensions. When you try to lookup a template name that matches the
# file extension, Tilt will automatically try to require the filename and
# constantize the class name.
#
# Unlike {#register}, there can be multiple template implementations
# registered lazily to the same file extension. Tilt will attempt to load the
# template implementations in order (registered *last* would be tried first),
# returning the first which doesn't raise LoadError.
#
# If all of the registered template implementations fails, Tilt will raise
# the exception of the first, since that was the most preferred one.
#
#     mapping = Tilt::Mapping.new
#     mapping.register_lazy('Bluecloth::Template', 'bluecloth/template', 'md')
#     mapping.register_lazy('RDiscount::Template', 'rdiscount/template', 'md')
#     mapping['index.md']
#     # => RDiscount::Template
#
# In the previous example we say that RDiscount has a *higher priority* than
# BlueCloth. Tilt will first try to `require "rdiscount/template"`, falling
# back to `require "bluecloth/template"`. If none of these are successful,
# the first error will be raised.
#
# source://tilt//lib/tilt/mapping.rb#50
class Tilt::Mapping
  # @return [Mapping] a new instance of Mapping
  #
  # source://tilt//lib/tilt/mapping.rb#54
  def initialize; end

  # Looks up a template class based on file name and/or extension.
  #
  # @example
  #   mapping['views/hello.erb'] # => Tilt::ERBTemplate
  #   mapping['hello.erb']       # => Tilt::ERBTemplate
  #   mapping['erb']             # => Tilt::ERBTemplate
  # @return [template class]
  #
  # source://tilt//lib/tilt/mapping.rb#152
  def [](file); end

  # Finds the extensions the template class has been registered under.
  #
  # @param template_class [template class]
  #
  # source://tilt//lib/tilt/mapping.rb#183
  def extensions_for(template_class); end

  # @private
  #
  # source://tilt//lib/tilt/mapping.rb#52
  def lazy_map; end

  # Instantiates a new template class based on the file.
  #
  # @example
  #   mapping.new('index.mt') # => instance of MyEngine::Template
  # @raise [RuntimeError] if there is no template class registered for the
  #   file name.
  # @see Tilt::Template.new
  #
  # source://tilt//lib/tilt/mapping.rb#136
  def new(file, line = T.unsafe(nil), options = T.unsafe(nil), &block); end

  # Registers a template implementation by file extension. There can only be
  # one template implementation per file extension, and this method will
  # override any existing mapping.
  #
  # @example
  #   mapping.register MyEngine::Template, 'mt'
  #   mapping['index.mt'] # => MyEngine::Template
  # @param template_class
  # @param extensions [Array<String>] List of extensions.
  # @return [void]
  #
  # source://tilt//lib/tilt/mapping.rb#104
  def register(template_class, *extensions); end

  # Registers a lazy template implementation by file extension. You
  # can have multiple lazy template implementations defined on the
  # same file extension, in which case the template implementation
  # defined *last* will be attempted loaded *first*.
  #
  # @example
  #   mapping.register_lazy 'MyEngine::Template', 'my_engine/template',  'mt'
  #
  #   defined?(MyEngine::Template) # => false
  #   mapping['index.mt'] # => MyEngine::Template
  #   defined?(MyEngine::Template) # => true
  # @param class_name [String] Class name of a template class.
  # @param file [String] Filename where the template class is defined.
  # @param extensions [Array<String>] List of extensions.
  # @return [void]
  #
  # source://tilt//lib/tilt/mapping.rb#81
  def register_lazy(class_name, file, *extensions); end

  # Checks if a file extension is registered (either eagerly or
  # lazily) in this mapping.
  #
  # @example
  #   mapping.registered?('erb')  # => true
  #   mapping.registered?('nope') # => false
  # @param ext [String] File extension.
  # @return [Boolean]
  #
  # source://tilt//lib/tilt/mapping.rb#123
  def registered?(ext); end

  # Looks up a template class based on file name and/or extension.
  #
  # @example
  #   mapping['views/hello.erb'] # => Tilt::ERBTemplate
  #   mapping['hello.erb']       # => Tilt::ERBTemplate
  #   mapping['erb']             # => Tilt::ERBTemplate
  # @return [template class]
  #
  # source://tilt//lib/tilt/mapping.rb#152
  def template_for(file); end

  # @private
  #
  # source://tilt//lib/tilt/mapping.rb#52
  def template_map; end

  # Looks up a list of template classes based on file name. If the file name
  # has multiple extensions, it will return all template classes matching the
  # extensions from the end.
  #
  # @example
  #   mapping.templates_for('views/index.haml.erb')
  #   # => [Tilt::ERBTemplate, Tilt::HamlTemplate]
  # @return [Array<template class>]
  #
  # source://tilt//lib/tilt/mapping.rb#168
  def templates_for(file); end

  private

  # The proper behavior (in MRI) for autoload? is to
  # return `false` when the constant/file has been
  # explicitly required.
  #
  # However, in JRuby it returns `true` even after it's
  # been required. In that case it turns out that `defined?`
  # returns `"constant"` if it exists and `nil` when it doesn't.
  # This is actually a second bug: `defined?` should resolve
  # autoload (aka. actually try to require the file).
  #
  # We use the second bug in order to resolve the first bug.
  #
  # @return [Boolean]
  #
  # source://tilt//lib/tilt/mapping.rb#277
  def constant_defined?(name); end

  # @private
  #
  # source://tilt//lib/tilt/mapping.rb#60
  def initialize_copy(other); end

  # @return [Boolean]
  #
  # source://tilt//lib/tilt/mapping.rb#196
  def lazy?(ext); end

  # source://tilt//lib/tilt/mapping.rb#221
  def lazy_load(pattern); end

  # source://tilt//lib/tilt/mapping.rb#215
  def lookup(ext); end

  # source://tilt//lib/tilt/mapping.rb#201
  def split(file); end
end

# source://tilt//lib/tilt/mapping.rb#263
Tilt::Mapping::AUTOLOAD_IS_BROKEN = T.let(T.unsafe(nil), T.untyped)

# source://tilt//lib/tilt/mapping.rb#219
Tilt::Mapping::LOCK = T.let(T.unsafe(nil), Monitor)

# Nokogiri template implementation. See:
# http://nokogiri.org/
#
# source://tilt//lib/tilt/nokogiri.rb#7
class Tilt::NokogiriTemplate < ::Tilt::Template
  # source://tilt//lib/tilt/nokogiri.rb#13
  def evaluate(scope, locals); end

  # source://tilt//lib/tilt/nokogiri.rb#27
  def precompiled_postamble(locals); end

  # source://tilt//lib/tilt/nokogiri.rb#22
  def precompiled_preamble(locals); end

  # source://tilt//lib/tilt/nokogiri.rb#31
  def precompiled_template(locals); end

  # source://tilt//lib/tilt/nokogiri.rb#11
  def prepare; end
end

# source://tilt//lib/tilt/nokogiri.rb#8
Tilt::NokogiriTemplate::DOCUMENT_HEADER = T.let(T.unsafe(nil), Regexp)

# Raw text (no template functionality).
#
# source://tilt//lib/tilt/plain.rb#6
class Tilt::PlainTemplate < ::Tilt::Template
  # source://tilt//lib/tilt/plain.rb#12
  def evaluate(scope, locals, &block); end

  # source://tilt//lib/tilt/plain.rb#9
  def prepare; end
end

# RDoc template. See:
# http://rdoc.rubyforge.org/
#
# It's suggested that your program `require 'rdoc/markup'` and
# `require 'rdoc/markup/to_html'` at load time when using this template
# engine in a threaded environment.
#
# source://tilt//lib/tilt/rdoc.rb#13
class Tilt::RDocTemplate < ::Tilt::Template
  # @return [Boolean]
  #
  # source://tilt//lib/tilt/rdoc.rb#36
  def allows_script?; end

  # source://tilt//lib/tilt/rdoc.rb#32
  def evaluate(scope, locals, &block); end

  # source://tilt//lib/tilt/rdoc.rb#16
  def markup; end

  # source://tilt//lib/tilt/rdoc.rb#27
  def prepare; end
end

# Standalone string interpolator and template processor implementation in Go.
# see: https://github.com/gliderlabs/sigil
#
# source://tilt//lib/tilt/sigil.rb#7
class Tilt::SigilTemplate < ::Tilt::Template
  # @return [Boolean]
  #
  # source://tilt//lib/tilt/sigil.rb#30
  def allows_script?; end

  # source://tilt//lib/tilt/sigil.rb#11
  def evaluate(scope, locals, &block); end

  # source://tilt//lib/tilt/sigil.rb#8
  def prepare; end
end

# The template source is evaluated as a Ruby string. The #{} interpolation
# syntax can be used to generated dynamic output.
#
# source://tilt//lib/tilt/string.rb#6
class Tilt::StringTemplate < ::Tilt::Template
  # source://tilt//lib/tilt/string.rb#16
  def precompiled(locals); end

  # source://tilt//lib/tilt/string.rb#12
  def precompiled_template(locals); end

  # source://tilt//lib/tilt/string.rb#7
  def prepare; end
end

# @private
#
# source://tilt//lib/tilt/template.rb#5
Tilt::TOPOBJECT = Tilt::CompiledTemplates

# Base class for template implementations. Subclasses must implement
# the #prepare method and one of the #evaluate or #precompiled_template
# methods.
#
# source://tilt//lib/tilt/template.rb#21
class Tilt::Template
  # Create a new template with the file, line, and options specified. By
  # default, template data is read from the file. When a block is given,
  # it should read template data and return as a String. When file is nil,
  # a block is required.
  #
  # All arguments are optional.
  #
  # @raise [ArgumentError]
  # @return [Template] a new instance of Template
  #
  # source://tilt//lib/tilt/template.rb#60
  def initialize(file = T.unsafe(nil), line = T.unsafe(nil), options = T.unsafe(nil), &block); end

  # The basename of the template file.
  #
  # source://tilt//lib/tilt/template.rb#115
  def basename(suffix = T.unsafe(nil)); end

  # Template source; loaded from a file or given directly.
  #
  # source://tilt//lib/tilt/template.rb#23
  def data; end

  # The filename used in backtraces to describe the template.
  #
  # source://tilt//lib/tilt/template.rb#125
  def eval_file; end

  # The name of the file where the template data was loaded from.
  #
  # source://tilt//lib/tilt/template.rb#26
  def file; end

  # The line number in #file where template data was loaded from.
  #
  # source://tilt//lib/tilt/template.rb#29
  def line; end

  # An empty Hash that the template engine can populate with various
  # metadata.
  #
  # source://tilt//lib/tilt/template.rb#131
  def metadata; end

  # The template file's basename with all extensions chomped off.
  #
  # source://tilt//lib/tilt/template.rb#120
  def name; end

  # A Hash of template engine specific options. This is passed directly
  # to the underlying engine and is not used by the generic template
  # interface.
  #
  # source://tilt//lib/tilt/template.rb#34
  def options; end

  # Render the template in the given scope with the locals specified. If a
  # block is given, it is typically available within the template via
  # +yield+.
  #
  # source://tilt//lib/tilt/template.rb#105
  def render(scope = T.unsafe(nil), locals = T.unsafe(nil), &block); end

  protected

  # The encoding of the source data. Defaults to the
  # default_encoding-option if present. You may override this method
  # in your template class if you have a better hint of the data's
  # encoding.
  #
  # source://tilt//lib/tilt/template.rb#147
  def default_encoding; end

  # Execute the compiled template and return the result string. Template
  # evaluation is guaranteed to be performed in the scope object with the
  # locals specified and with support for yielding to the block.
  #
  # This method is only used by source generating templates. Subclasses that
  # override render() may not support all features.
  #
  # source://tilt//lib/tilt/template.rb#168
  def evaluate(scope, locals, &block); end

  # Generates all template source by combining the preamble, template, and
  # postamble and returns a two-tuple of the form: [source, offset], where
  # source is the string containing (Ruby) source code for the template and
  # offset is the integer line offset where line reporting should begin.
  #
  # Template subclasses may override this method when they need complete
  # control over source generation or want to adjust the default line
  # offset. In most cases, overriding the #precompiled_template method is
  # easier and more appropriate.
  #
  # source://tilt//lib/tilt/template.rb#193
  def precompiled(local_keys); end

  # source://tilt//lib/tilt/template.rb#227
  def precompiled_postamble(local_keys); end

  # source://tilt//lib/tilt/template.rb#223
  def precompiled_preamble(local_keys); end

  # A string containing the (Ruby) source code for the template. The
  # default Template#evaluate implementation requires either this
  # method or the #precompiled method be overridden. When defined,
  # the base Template guarantees correct file/line handling, locals
  # support, custom scopes, proper encoding, and support for template
  # compilation.
  #
  # @raise [NotImplementedError]
  #
  # source://tilt//lib/tilt/template.rb#219
  def precompiled_template(local_keys); end

  # Do whatever preparation is necessary to setup the underlying template
  # engine. Called immediately after template data is loaded. Instance
  # variables set in this method are available when #evaluate is called.
  #
  # Subclasses must provide an implementation of this method.
  #
  # @raise [NotImplementedError]
  #
  # source://tilt//lib/tilt/template.rb#156
  def prepare; end

  private

  # source://tilt//lib/tilt/template.rb#300
  def binary(string); end

  # source://tilt//lib/tilt/template.rb#261
  def compile_template_method(local_keys, scope_class = T.unsafe(nil)); end

  # The compiled method for the locals keys provided.
  #
  # source://tilt//lib/tilt/template.rb#245
  def compiled_method(locals_keys, scope_class = T.unsafe(nil)); end

  # source://tilt//lib/tilt/template.rb#290
  def extract_encoding(script); end

  # source://tilt//lib/tilt/template.rb#294
  def extract_magic_comment(script); end

  # source://tilt//lib/tilt/template.rb#251
  def local_extraction(local_keys); end

  # source://tilt//lib/tilt/template.rb#235
  def read_template_file; end

  # source://tilt//lib/tilt/template.rb#284
  def unbind_compiled_method(method_name); end

  class << self
    # @deprecated Use `.metadata[:mime_type]` instead.
    #
    # source://tilt//lib/tilt/template.rb#44
    def default_mime_type; end

    # @deprecated Use `.metadata[:mime_type] = val` instead.
    #
    # source://tilt//lib/tilt/template.rb#49
    def default_mime_type=(value); end

    # An empty Hash that the template engine can populate with various
    # metadata.
    #
    # source://tilt//lib/tilt/template.rb#39
    def metadata; end
  end
end

# source://tilt//lib/tilt/template.rb#160
Tilt::Template::CLASS_METHOD = T.let(T.unsafe(nil), UnboundMethod)

# Current version.
#
# source://tilt//lib/tilt.rb#7
Tilt::VERSION = T.let(T.unsafe(nil), String)
