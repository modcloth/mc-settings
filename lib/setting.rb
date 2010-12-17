require 'singleton'
class Setting
  class SettingNotFound < RuntimeError; end
  class SettingFileError < RuntimeError; end

  include Singleton

  def self.reload params = {}
    @available_settings = {}
    self.load params
  end

  def self.available_settings
    self.instance ? @available_settings : {}
  end

  # get a setting value by [] notation
  def self.[](name)
    self.check_value(name.to_s)
    self.value_for(name.to_s)
  end

  def self.method_missing(method, *args, &block)
    # see if this method is defined above us in the hierarchy
    super(method, *args)
  rescue
    name = method.to_s
    if name[-1, 1] == "?"
      name.chomp!('?')
      self[name]['default'].to_i > 0
    else
      self[name]
    end
  end

  def initialize
    @available_settings ||= {}
  end

  class << self
    def has_key?(key)
      @available_settings.has_key?(key)
    end

    def value_for(value)
      v = @available_settings[value]
      if v.is_a?(Hash) && v.size > 1
        v
      elsif v.is_a?(Hash) && v.has_key?("default")
        v['default'].nil? ? "" : v['default']
      else
        v
      end
    end
  end

  def self.load(params)
    files = []
    path  = params[:path]
    params[:files].each do |file|
      files << File.join(path, file)
    end
    if params[:local]
      files << Dir.glob(File.join(path, 'local', '*.yml'))
    end
    @available_settings ||= {}
    files.flatten.each do |file|
      begin
        @available_settings.merge!(YAML::load(File.open(file)) || {}) if File.exists?(file)
      rescue Exception => e
        raise SettingNotFound.new("Error parsing file #{file}, with: #{e.message}")
      end
    end
    @available_settings
  end

  private

  def self.check_value(name)
    raise RuntimeError.new("settings are not yet initialized") unless self.instance
    raise SettingNotFound.new("#{name} not found") unless self.has_key?(name)
  end

end