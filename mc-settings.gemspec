# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative 'lib/mc-settings/version'

Gem::Specification.new do |s|
  s.name                      = 'mc-settings'
  s.version                   = Setting::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors                   = ["Edwin Cruz", "Colin Shield", "Konstantin Gredeskoul"]
  s.date                      = '2020-09-01'
  s.description               = 'Manage application configuration and settings per deployment environment'
  s.summary                   = 'Manage application configuration and settings per deployment environment'
  s.email                     = %w[softr8@gmail.com kigster@gmail.com]
  s.files                     = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.extra_rdoc_files          = %w[LICENSE.txt README.adoc]
  s.homepage                  = 'https://github.com/modcloth/mc-settings'
  s.licenses                  = ["MIT"]
  s.require_paths             = ["lib"]
  s.test_files                = %w[spec/mc_settings_spec.rb spec/spec_helper.rb spec/support/settings_helper.rb]

  s.add_development_dependency('bundler')
  s.add_development_dependency('rspec', '~> 3.0')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('rake')
  s.add_development_dependency('pry-byebug')
  s.add_development_dependency('rspec-mocks')
  s.add_development_dependency('asciidoctor')
  s.add_development_dependency('rspec-expectations')
end
