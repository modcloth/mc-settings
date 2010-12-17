class Setting
  class SettingNotFound < RuntimeError;
  end
  class SettingFileError < RuntimeError;
  end

  attr_reader :available_settings

  @@instance = nil

  def self.load params = {}
    raise RuntimeError.new("Settings already initialized") if @@instance
    reload(params)
  end

  def self.reload params = {}
    @@instance = Setting.new(params)
  end

  def self.available_settings
    @@instance ? @@instance.available_settings : {}
  end

  # get a setting value by [] notation
  def self.[](name)
    check_value(name.to_s)
    @@instance.value_for(name.to_s)
  end

  def self.method_missing(method, *args, &block)
    # see if this method is defined above us in the hierarchy
    super(method, *args)
  rescue NoMethodError
    name = method.to_s
    if name[-1, 1] == "?"
      name.chomp!('?')
      self[name]['default'].to_i > 0
    else
      self[name]
    end
  end


  def self.instance
    @@instance
  end

#   def self.per_page_options_array
#    self.per_page_options.split(%r{[\s,]}).collect(&:to_i).select {|n| n > 0}.sort
#  end

  #=================================================================================

  def initialize(params = {})
    load params
  end

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

  private

  def self.check_value(name)
    raise RuntimeError.new("settings are not yet initialized") unless @@instance
    raise SettingNotFound.new("#{name} not found") unless @@instance.has_key?(name)
  end

  def load(params)
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
end