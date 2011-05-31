require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe Setting do
  subject { Setting }

  context "Test with stubs" do
    before :each do
      stub_setting_files
      Setting.reload(
          :path  => "config/settings",
          :files => ["default.yml", "environments/test.yml"],
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
      Setting[:six].should == {"default"=>"default value", "extra"=>"recursively overriden", "deep_level"=>{"value"=>"even deeper level"}}
      Setting.available_settings['six']['default'].should == "default value"
      Setting.seven.should == "seven from custom"
    end

    it "handles default key" do
      Setting.default_setting.should == 1
      Setting['seven']['default'].should == "seven from custom"
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

    it "should merge keys recursivelly" do
      Setting.six(:extra).should == "recursively overriden"
      Setting.six(:deep_level, :value).should == "even deeper level"
    end

    it "should create keys if it does not exist" do
      Setting.test_specific.should == "exist"
    end

    context "working with arrays" do
      it "should replace the whole array instead of appending new values" do
        Setting.nested_array.should == ['first', 'four', 'five']
      end
    end
  end

  context "When running with threads" do
    it "should keep its values" do
      3.times do |time|
        Thread.new {
          Setting.available_settings.shoud_not be_empty
        }
      end
    end
  end

  context "Test from file" do
    before :each do
      Setting.reload(
         :path  => File.join(File.dirname(__FILE__)) + '/fixtures',
         :files => ['sample.yml']
      )
    end

    it 'should support [] syntax' do
      Setting['tax']['default'].should == 0.0
      Setting['tax'].should == { 'default' => 0.0, 'california' => 7.5 }
    end

    it 'should support method invocation syntax' do
      Setting.tax.should == 0.0

      Setting.tax(:default).should     == Setting.tax
      Setting.tax('default').should    == Setting.tax
      Setting.tax(:california).should  == 7.5

      Setting.states.should            == ['CA', 'WA', 'NY']
      Setting.states(:default).should  == Setting.states
      Setting.states(:ship_to).should  == ['CA', 'NY']
    end

    it 'should correctly process Boolean values' do
      Setting.boolean_true?.should be(true)
      Setting.boolean_true.should == 4
      Setting.boolean_false?.should be(false)
      Setting.boolean_false?(:default).should be(false)
      Setting.boolean_false?(:negated).should be(true)
    end
  end

  context "Test recursive overrides and nested hashes" do
    before :each do
      Setting.reload(
         :path  => File.join(File.dirname(__FILE__)) + '/fixtures',
         :files => ['sample.yml', 'joes-colors.yml']
      )
    end

    it 'should override colors with Joes and support nested hashes' do
      Setting.color.should == :grey # default
      Setting.color(:pants).should == :purple # default

      Setting.color(:pants, :school).should == :blue # in sample
      Setting.color(:pants, :favorite).should == :orange # joes override

      Setting.color(:shorts, :school).should == :black # in sample
      Setting.color(:shorts, :favorite).should == :white # joe's override

      Setting.color(:shorts).should == :stripes # joe's override of default
    end

  end
end