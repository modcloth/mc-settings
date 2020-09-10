# frozen_string_literal: true

require 'singleton'
require 'yaml'
require 'erb'

class Hash
  def recursive_merge!(other)
    other.keys.each do |k|
      if self[k].is_a?(Array) && other[k].is_a?(Array)
        self[k] = other[k]
      elsif self[k].is_a?(Hash) && other[k].is_a?(Hash)
        self[k].recursive_merge!(other[k])
      else
        self[k] = other[k]
      end
    end
    self
  end
end

class Setting
  class NotFound < RuntimeError; end

  class FileError < RuntimeError; end

  class AlreadyLoaded < RuntimeError; end

  include Singleton
  attr_reader :available_settings

  class << self
    # This method can be called only once.
    #
    # Parameter hash looks like this:
    #
    #  {  :files => [ "file1.yml", "file2.yml", ...],
    #     :path  => "/var/www/apps/my-app/current/config/settings",
    #     :local => true }
    #
    # If :local => true is set, we will load all *.yml files under :path/local directory
    # after all files in :files have been loaded.  "Local" settings thus take precedence
    # by design.  See README for more details.
    #
    def load(**args)
      raise AlreadyLoaded, 'Settings already loaded' if instance.loaded?

      instance.load(**args)
    end

    def reload(**args)
      instance.load(**args)
    end

    # In Method invocation syntax we collapse Hash values
    # and return a single value if 'default' is found among keys
    # or Hash has only one key/value pair.
    #
    # For example, if the YML data is:
    # tax:
    #   default: 0.0
    #   california: 7.5
    #
    # Then calling Setting.tax returns "0.0""
    #
    # This is the preferred method of using settings class.
    #
    def method_missing(method, *args)
      instance.value_for(method, args) do |v, args|
        instance.collapse_hashes(v, args)
      end
    end

    def respond_to_missing?
      true
    end

    # In [] invocation syntax, we return settings value 'as is' without
    # Hash conversions.
    #
    # For example, if the YML data is:
    # tax:
    #   default: 0.0
    #   california: 7.5
    #
    # Then calling Setting['tax'] returns
    #   { 'default' => "0.0", 'california' => "7.5"}

    def [](value)
      instance.value_for(value)
    end

    # <b>DEPRECATED:</b> Please use <tt>method accessors</tt> instead.
    def available_settings
      instance.available_settings
    end
  end

  # Instance Methods

  def initialize
    @available_settings = {}
  end

  # @param [Object] key
  def key?(key)
    @available_settings.key?(key) ||
      (key[-1, 1] == '?' && @available_settings.key?(key.chop))
  end

  alias has_key? key?

  def value_for(key, args = [])
    name = key.to_s
    unless key?(name)
      raise NotFound, "#{name} was not found"
    end

    bool = false
    if name[-1, 1] == '?'
      name.chop!
      bool = true
    end

    v = @available_settings[name]
    if block_given?
      v = yield(v, args)
    end

    if v.is_a?(Integer) && bool
      v.to_i > 0
    else
      v
    end
  end

  # This method performs collapsing of the Hash settings values if the Hash
  # contains 'default' value, or just 1 element.

  def collapse_hashes(v, args)
    out = if v.is_a?(Hash)
            if args.empty?
              if v.key?("default")
                v['default'].nil? ? "" : v['default']
              elsif v.keys.size == 1
                v.values.first
              else
                v
              end
            else
              v[args.shift.to_s]
            end
          else
            v
          end
    if out.is_a?(Hash) && !args.empty?
      collapse_hashes(out, args)
    elsif out.is_a?(Hash) && out.key?('default')
      out['default']
    else
      out
    end
  end

  def loaded?
    @loaded
  end

  def load(**params)
    # reset settings hash
    @available_settings = {}
    @loaded             = false

    files = []
    path  = params[:path] || Dir.pwd
    params[:files].each do |file|
      files << File.join(path, file)
    end
    if params[:local]
      files << Dir.glob(File.join(path, 'local', '*.yml')).sort
    end

    files.flatten.each do |file|
      if File.exist?(file)
        @available_settings.recursive_merge! load_file(file)
      end
    rescue StandardError => e
      raise FileError, "Error parsing file #{file}, with: #{e.message}"
    end

    @loaded = true
    @available_settings
  end

  private

  def load_file(file)
    ::YAML.load(
      ::ERB.new(::IO.read(file)).result,
      fallback: {},
    )
  end
end
