require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe Setting do
  subject { Setting }

  context 'Test with stubs' do
    before :each do
      stub_setting_files
      subject.reload(
          :path  => 'config/settings',
          :files => ['default.yml', 'environments/test.yml'],
          :local => true)
    end

    it 'should return test specific values' do
      expect(subject.available_settings['one']).to eq 'test'
      expect(subject.one).to eq 'test'
      expect(subject['one']).to eq 'test'
    end

    it 'should handle custom values overriding everything else' do
      expect(subject.seven).to eq 'seven from custom'
    end

    it "handles multiple values" do
      expect(subject[:six]).to eq({"default"=>"default value", "extra"=>"recursively overriden", "deep_level"=>{"value"=>"even deeper level"}})
      expect(subject.available_settings['six']['default']).to eq "default value"
      expect(subject.seven).to eq "seven from custom"
    end

    it "handles default key" do
      expect(subject.default_setting).to eq 1
      expect(subject['seven']['default']).to eq "seven from custom"
    end

    it "should handle empty strings" do
      expect(subject.empty).to eq ""
    end

    it "should responds to ? mark" do
      expect(subject.autologin?).to eq true
    end

    it "should returns false correctly" do
      expect(subject.flag_false).to be(false)
    end

    it "should merge keys recursivelly" do
      expect(subject.six(:extra)).to eq "recursively overriden"
      expect(subject.six(:deep_level, :value)).to eq "even deeper level"
    end

    it "should create keys if it does not exist" do
      expect(subject.test_specific).to eq "exist"
    end

    context "working with arrays" do
      it "should replace the whole array instead of appending new values" do
        expect(subject.nested_array).to eq ['first', 'four', 'five']
      end
    end
  end

  context "When running with threads" do
    it "should keep its values" do
      3.times do |time|
        Thread.new {
          expect(subject.available_settings).to_not be_empty
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
      expect(subject['tax']['default']).to eq 0.0
      expect(subject['tax']).to eq({ 'default' => 0.0, 'california' => 7.5 })
    end

    it 'should support method invocation syntax' do
      expect(subject.tax).to eq 0.0

      expect(subject.tax(:default)).to eq subject.tax
      expect(subject.tax('default')).to eq subject.tax
      expect(subject.tax(:california)).to eq 7.5

      expect(subject.states).to eq ['CA', 'WA', 'NY']
      expect(subject.states(:default)).to eq subject.states
      expect(subject.states(:ship_to)).to eq ['CA', 'NY']
    end

    it 'should correctly process Boolean values' do
      expect(subject.boolean_true?).to be(true)
      expect(subject.boolean_true).to eq 4
      expect(subject.boolean_false?).to be(false)
      expect(subject.boolean_false?(:default)).to be(false)
      expect(subject.boolean_false?(:negated)).to be(true)
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
      expect(subject.color).to eq :grey # default
      expect(subject.color(:pants)).to eq :purple # default

      expect(subject.color(:pants, :school)).to eq :blue # in sample
      expect(subject.color(:pants, :favorite)).to eq :orange # joes override

      expect(subject.color(:shorts, :school)).to eq :black # in sample
      expect(subject.color(:shorts, :favorite)).to eq :white # joe's override

      expect(subject.color(:shorts)).to eq :stripes # joe's override of default
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
      expect(subject.shipping_config).to eq "Defaulted"
      expect(subject.shipping_config(:domestic, :non_shippable_regions).first).to eq "US-AS"
      expect(subject.shipping_config(:international, :service)).to eq 'Foo'
      expect(subject.shipping_config(:international, :countries).size).to be > 0
      expect(subject.shipping_config(:international, :shipping_carrier)).to eq 'Bar'
      #backward compatibility:
      expect(subject.shipping_config(:domestic)['non_shippable_regions'].size).to be > 0
    end
  end

  context "Ruby code inside yml file" do
    before :each do
      subject.reload(
          :path  => File.join(File.dirname(__FILE__)) + '/fixtures',
          :files => ['shipping.yml']
      )
    end

    it 'should interpret ruby code and put correct values' do
      expect(subject.shipping_config).to eq 'Defaulted'
      expect(subject.number).to eq 5
      expect(subject.stringified).to eq 'stringified'
    end
  end
end
