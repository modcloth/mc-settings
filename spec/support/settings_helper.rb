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
    empty:
      default:
    autologin:
      format: int
      default: 7
    flag_false:
      default: false
CONTENT
  test = <<-CONTENT
    one: test
    two:
      three: 5
      four: "6"
    five: "test string"
  CONTENT

  empty = <<-CONTENT
  CONTENT

  custom = <<-CONTENT
    seven:
      default: "seven from custom"
  CONTENT

  File.stub!(:exists?).and_return(true)
  File.stub!(:exists?).with("config/settings/environments/development.yml").and_return(false)
  File.stub!(:open).with("config/settings/default.yml").and_return(defaults)
  File.stub!(:open).with("config/settings/environments/test.yml").and_return(test)
  File.stub!(:open).with("config/settings/local/custom.yml").and_return(custom)
  File.stub!(:open).with("config/settings/local/empty.yml").and_return(empty)

  Dir.stub!(:glob).and_return(["config/settings/local/empty.yml", "config/settings/local/custom.yml"])
end