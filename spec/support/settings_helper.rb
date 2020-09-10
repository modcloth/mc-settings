def stub_setting_files
  defaults = <<~YAML
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
  YAML

  test = <<~YAML
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
  YAML

  empty = <<~YAML
  YAML

  custom = <<~YAML
    seven:
      default: "seven from custom"
  YAML

  %w[
    config/settings/default.yml
    config/settings/environments/test.yml
    config/settings/local/custom.yml
    config/settings/local/empty.yml
  ].each do |path|
    allow(File).to receive(:exist?).with(path).and_return(true)
  end

  allow(File).to receive(:exist?).with("config/settings/environments/development.yml").and_return(false)

  allow(IO).to receive(:read).with("config/settings/default.yml").and_return(defaults)
  allow(IO).to receive(:read).with("config/settings/environments/test.yml").and_return(test)
  allow(IO).to receive(:read).with("config/settings/local/custom.yml").and_return(custom)
  allow(IO).to receive(:read).with("config/settings/local/empty.yml").and_return(empty)

  allow(Dir).to receive(:glob).and_return(%w[config/settings/local/empty.yml config/settings/local/custom.yml])
end
