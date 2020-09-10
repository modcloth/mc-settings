# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'mc-settings'
describe Setting do
  subject { described_class }

  context "Test with stubs" do
    before :each do
      stub_setting_files
      subject.reload(
        path:  "config/settings",
        files: %w[default.yml environments/test.yml],
        local: true
      )
    end

    it 'should return test specific values' do
      expect(subject.available_settings['one']).to eql "test"
      expect(subject.one).to eql "test"
      expect(subject['one']).to eql "test"
    end

    it "should handle custom values overriding everything else" do
      expect(subject.seven).to eql "seven from custom"
    end

    let(:six) { { "default" => "default value", "extra" => "recursively overriden", "deep_level" => { "value" => "even deeper level" } } }

    it "handles multiple values" do
      expect(subject[:six]).to eql six
      expect(subject.available_settings['six']['default']).to eql "default value"
      expect(subject.seven).to eql "seven from custom"
    end

    it "handles default key" do
      expect(subject.default_setting).to eql 1
      expect(subject['seven']['default']).to eql "seven from custom"
    end

    it "should handle empty strings" do
      expect(subject.empty).to eql ""
    end

    it "should responds to ? mark" do
      expect(subject.autologin?).to eql true
    end

    it "should returns false correctly" do
      expect(subject.flag_false).to be_falsey
    end

    it "should merge keys recursively" do
      expect(subject.six(:extra)).to eql "recursively overriden"
      expect(subject.six(:deep_level, :value)).to eql "even deeper level"
    end

    it "should create keys if it does not exist" do
      expect(subject.test_specific).to eql "exist"
    end

    context "working with arrays" do
      it "should replace the whole array instead of appending new values" do
        expect(subject.nested_array).to eql %w[first four five]
      end
    end
  end

  context "When running with threads" do
    it "should keep its values" do
      3.times do |_time|
        Thread.new {
          expect(subject.available_settings).not_to be_empty
        }
      end
    end
  end

  context "Test from file" do
    before :each do
      subject.reload(
        path:  File.join(File.dirname(__FILE__)) + '/fixtures',
        files: ['sample.yml']
      )
    end

    it 'should support [] syntax' do
      expect(subject['tax']['default']).to eql 0.0
      expect(subject['tax']).to eql( 'default' => 0.0, 'california' => 7.5 )
    end

    it 'should support method invocation syntax' do
      expect(subject.tax).to eql 0.0
      expect(subject.states).to eql  %w[CA WA NY]
      expect(subject.tax(:default)).to eql subject.tax
      expect(subject.tax('default')).to eql subject.tax
      expect(subject.tax(:california)).to eql 7.5
      expect(subject.states(:default)).to eql subject.states
      expect(subject.states(:ship_to)).to eql %w[CA NY]
    end

    it 'should correctly process Boolean values' do
      expect(subject.boolean_true?).to be_truthy
      expect(subject.boolean_true).to eql 4
      expect(subject.boolean_false?).to be_falsey
      expect(subject.boolean_false?(:default)).to be_falsey
      expect(subject.boolean_false?(:negated)).to be_truthy
    end
  end

  context "Test recursive overrides and nested hashes" do
    before :each do
      subject.reload(
        path:  File.join(File.dirname(__FILE__)) + '/fixtures',
        files: %w[sample.yml joes-colors.yml]
      )
    end

    it 'should override colors with Joes and support nested hashes' do
      expect(subject.color).to eql :grey # default
      expect(subject.color(:pants)).to eql :purple # default
      expect(subject.color(:pants, :school)).to eql :blue # in sample
      expect(subject.color(:pants, :favorite)).to eql :orange # joes override
      expect(subject.color(:shorts,:school)).to eql :black # in sample
      expect(subject.color(:shorts, :favorite)).to eql :white # joe's override
      expect(subject.color(:shorts)).to  eql :stripes # joe's override of default
    end
  end

  context "Complex nested configs" do
    before :each do
      subject.reload(
        path:  File.join(File.dirname(__FILE__)) + '/fixtures',
        files: ['shipping.yml']
      )
    end

    it "should build correct tree with arrays and default values " do
      expect(subject.shipping_config).to eql "Defaulted"
      expect(subject.shipping_config(:domestic, :non_shippable_regions).first).to eql "US-AS"
      expect(subject.shipping_config(:international, :service)).to eql 'Foo'
      expect(subject.shipping_config(:international, :countries).size).to be > 0
      expect(subject.shipping_config(:international, :shipping_carrier)).to eql 'Bar'
      expect(subject.shipping_config(:domestic)['non_shippable_regions'].size).to be > 0
    end
  end

  context "Ruby code inside yml file" do
    before :each do
      subject.reload(
        path:  File.join(File.dirname(__FILE__)) + '/fixtures',
        files: ['shipping.yml']
      )
    end
    it "should interpret ruby code and put correct values" do
      expect(subject.shipping_config).to eql "Defaulted"
      expect(subject.number).to eql 5
      expect(subject.stringified).to eql "stringified"
    end
  end
end
