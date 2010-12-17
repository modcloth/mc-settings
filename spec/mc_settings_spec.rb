require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe Setting do
  subject { Setting }

  context "Test environment" do
    before :each do
      stub_setting_files
      Setting.reload(
          :files => ["default.yml", "environments/test.yml"],
          :path  => "config/settings",
          :local => true)
    end
    it 'should return test specific values' do
      Setting.available_settings['one'].should == "test"
      Setting.one.should == "test"
      Setting['one'].should == "test"
    end

    it "should handle custom values overriding everything else" do
      Setting.seven.should == "seven from custom"
    end

    it "handles multiple values" do
      Setting['six'].should == {"default"=>"default value", "extra"=>"extra"}
      Setting.available_settings['six']['default'].should == "default value"
      Setting.available_settings['six']['extra'].should == "extra"
      Setting.seven.should == "seven from custom"
    end

    it "should support symbols as keys" do
      Setting[:six].should == {"default"=>"default value", "extra"=>"extra"}
    end
    it "handles default key" do
      Setting.default_setting.should == 1
      Setting['seven'].should == "seven from custom"
    end

    it "should handle empty strings" do
      Setting.empty.should == ""
    end

    it "should responds to ? mark" do
      Setting.autologin?.should == true
    end

    it "should returns false correctly" do
      Setting.flag_false.should be(false)
    end
  end
end