def stub_setting_files
  defaults = <<-CONTENT
    one: default
    two:
      three: 3
      four: "4"
    five: "default string"
    default_setting: 1
    six:
      default: "default value"
      extra: "extra"
    seven:
      default: "seven"
  CONTENT
  test = <<-CONTENT
    one: test
    two:
      three: 5
      four: "6"
    five: "test string"
  CONTENT

  custom = <<-CONTENT
    seven:
      default: "seven from custom"
  CONTENT

  File.stub!(:exists?).and_return(true)
  File.stub!(:exists?).with("./config/settings/development.yml").and_return(false)
  File.stub!(:open).with("./config/settings/default.yml").and_return(defaults)
  File.stub!(:open).with("./config/settings/test.yml").and_return(test)
  File.stub!(:open).with("./config/settings/custom.yml").and_return(custom)

end