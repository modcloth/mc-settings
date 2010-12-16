class Setting
  class SettingNotFound < RuntimeError; end

  attr_reader :available_settings

  @@instance = nil

  def self.load *files
    raise RuntimeError.new("Settings already initialized") if @@instance
    reload(files)
  end

  def self.reload files
    @@instance = Setting.new(files)
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
      self[name].to_i > 0
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

  def initialize(files)
    load files
  end

  def has_key?(key)
    @available_settings.has_key?(key)
  end

  def value_for(value)
    v = @available_settings[value]
    if v.is_a?(Hash) && v.size > 1
      v
    elsif v.is_a?(Hash) && v.has_key?("default")
      # if not passing ["key"]["default"] return default value
      # if ["key"] only, return
      v['default']
    else
      v
    end
  end

  private

    def self.check_value(name)
      raise RuntimeError.new("settings are not yet initialized") unless @@instance
      raise SettingNotFound.new("#{name} not found") unless @@instance.has_key?(name)
    end
  
    def load(files)
      @available_settings ||= {}
      files.each do |file|
         path = File.join(Rails.root, file)
         @available_settings.merge!(YAML::load(File.open(path))) if File.exists?(path)
      end
    end

end