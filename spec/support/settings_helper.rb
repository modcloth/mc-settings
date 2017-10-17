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
      deep_level:
        value: "even deeper level"
    seven:
      default: "seven"
    empty:
      default:
    autologin:
      format: int
      default: 7
    flag_false:
      default: false
    nested_array:
      - first
      - second
      - third
CONTENT
  test = <<-CONTENT
    one: test
    two:
      three: 5
      four: "6"
    five: "test string"
    six:
      extra: "recursively overriden"
    test_specific: "exist"
    nested_array:
      - first
      - four
      - five
  CONTENT

  empty = <<-CONTENT
  CONTENT

  custom = <<-CONTENT
    seven:
      default: "seven from custom"
  CONTENT

  File.stub(:exists?).and_return(true)
  File.stub(:exists?).with("config/settings/environments/development.yml").and_return(false)
  IO.stub(:read).with("config/settings/default.yml").and_return(defaults)
  IO.stub(:read).with("config/settings/environments/test.yml").and_return(test)
  IO.stub(:read).with("config/settings/local/custom.yml").and_return(custom)
  IO.stub(:read).with("config/settings/local/empty.yml").and_return(empty)

  Dir.stub(:glob).and_return(["config/settings/local/empty.yml", "config/settings/local/custom.yml"])
end
