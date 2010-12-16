require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
class Rails

end
describe Setting do
  subject { Setting }

  context "Test environment" do
    before :each do
      Rails.stub!(:root).and_return('./')
      stub_setting_files
      begin
        Setting.load("config/settings/default.yml", "config/settings/test.yml", "config/settings/custom.yml")
      rescue
      end
    end
    it 'should return test specific values' do
      Setting.available_settings['one'].should == "test"
      Setting.one.should == "test"
      Setting['one'].should == "test"
      Setting.seven.should == "seven from custom"
    end
    it "handles multiple values" do

      Setting['six'].should == {"default"=>"default value", "extra"=>"extra"}
#      Setting['six', 'extra'].should == "extra"
#      Setting['six', 'default'].should == "extra"

      Setting[:six].should == {"default"=>"default value", "extra"=>"extra"}
#      Setting[:six, :extra].should == "extra"
#      Setting[:six, :default].should == "extra"

      Setting.available_settings['six']['extra'].should == "extra"

      Setting.seven.should == "seven from custom"

      #Setting['six']['default'].should == "default value"
    end
    it "handles default key" do
      Setting.default_setting.should == 1
      Setting['seven'].should == "seven from custom"
      #Setting['seven']['default'].should == "seven"
    end
  end
end