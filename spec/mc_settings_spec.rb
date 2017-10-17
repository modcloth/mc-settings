require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe Setting do
  subject { Setting }

  context "Test with stubs" do
    before :each do
      stub_setting_files
      subject.reload(
          :path  => "config/settings",
          :files => ["default.yml", "environments/test.yml"],
          :local => true)
    end

    it 'should return test specific values' do
      subject.available_settings['one'].should == "test"
      expect(subject.respond_to?(:one)).to eq(true)
      subject.one.should == "test"
      subject['one'].should == "test"
    end

    it "should handle custom values overriding everything else" do
      subject.seven.should == "seven from custom"
    end

    it "handles multiple values" do
      subject[:six].should == {"default"=>"default value", "extra"=>"recursively overriden", "deep_level"=>{"value"=>"even deeper level"}}
      subject.available_settings['six']['default'].should == "default value"
      subject.seven.should == "seven from custom"
    end

    it "handles default key" do
      subject.default_setting.should == 1
      subject['seven']['default'].should == "seven from custom"
    end

    it "should handle empty strings" do
      subject.empty.should == ""
    end

    it "should responds to ? mark" do
      expect(subject.respond_to?(:autologin?)).to eq(true)
      subject.autologin?.should == true
    end

    it "should returns false correctly" do
      subject.flag_false.should be(false)
    end

    it "should merge keys recursivelly" do
      subject.six(:extra).should == "recursively overriden"
      subject.six(:deep_level, :value).should == "even deeper level"
    end

    it "should create keys if it does not exist" do
      subject.test_specific.should == "exist"
      expect(subject.respond_to?(:test_specific)).to eq(true)
    end

    context "working with arrays" do
      it "should replace the whole array instead of appending new values" do
        subject.nested_array.should == ['first', 'four', 'five']
      end
    end
  end

  context "When running with threads" do
    it "should keep its values" do
      3.times do |time|
        Thread.new {
          subject.available_settings.shoud_not be_empty
        }
      end
    end
  end

  context "Test from file" do
    before :each do
      subject.reload(
         :path  => File.join(File.dirname(__FILE__)) + '/fixtures',
         :files => ['sample.yml']
      )
    end

    it 'should support [] syntax' do
      subject['tax']['default'].should == 0.0
      subject['tax'].should == { 'default' => 0.0, 'california' => 7.5 }
      expect(subject.respond_to?(:[])).to eq(true)
    end

    it 'should support method invocation syntax' do
      subject.tax.should == 0.0

      subject.tax(:default).should     == subject.tax
      subject.tax('default').should    == subject.tax
      subject.tax(:california).should  == 7.5

      subject.states.should            == ['CA', 'WA', 'NY']
      subject.states(:default).should  == subject.states
      subject.states(:ship_to).should  == ['CA', 'NY']
    end

    it 'should correctly process Boolean values' do
      subject.boolean_true?.should be(true)
      subject.boolean_true.should == 4
      subject.boolean_false?.should be(false)
      subject.boolean_false?(:default).should be(false)
      subject.boolean_false?(:negated).should be(true)
    end
  end

  context "Test recursive overrides and nested hashes" do
    before :each do
      subject.reload(
         :path  => File.join(File.dirname(__FILE__)) + '/fixtures',
         :files => ['sample.yml', 'joes-colors.yml']
      )
    end

    it 'should override colors with Joes and support nested hashes' do
      subject.color.should == :grey # default
      subject.color(:pants).should == :purple # default

      subject.color(:pants, :school).should == :blue # in sample
      subject.color(:pants, :favorite).should == :orange # joes override

      subject.color(:shorts, :school).should == :black # in sample
      subject.color(:shorts, :favorite).should == :white # joe's override

      subject.color(:shorts).should == :stripes # joe's override of default
    end

  end
  context "Complex nested configs" do
    before :each do
      subject.reload(
          :path  => File.join(File.dirname(__FILE__)) + '/fixtures',
          :files => ['shipping.yml']
      )
    end
    it "should build correct tree with arrays and default values " do
      subject.shipping_config.should == "Defaulted"
      subject.shipping_config(:domestic, :non_shippable_regions).first.should == "US-AS"
      subject.shipping_config(:international, :service).should == 'Foo'
      subject.shipping_config(:international, :countries).size.should > 0
      subject.shipping_config(:international, :shipping_carrier).should == 'Bar'
      #backward compatibility:
      subject.shipping_config(:domestic)['non_shippable_regions'].size.should > 0
    end
  end

  context "Ruby code inside yml file" do
    before :each do
      subject.reload(
          :path  => File.join(File.dirname(__FILE__)) + '/fixtures',
          :files => ['shipping.yml']
      )
    end
    it "should interpret ruby code and put correct values" do
      subject.shipping_config.should == "Defaulted"
      subject.number == 5
      subject.stringified == "stringified"
    end
  end
end
