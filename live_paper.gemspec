# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'live_paper/version'

Gem::Specification.new do |spec|
  spec.name          = "live_paper"
  spec.version       = LivePaper::VERSION
  spec.authors       = ["Mike Whitmarsh", "William Hertling"]
  spec.summary       = %q{Ruby interface to the Live Paper service by HP.}
  spec.description   = %q{Ruby interface to use the Live Paper service by HP for creating watermarked images, mobile-friendly shortened URLs, and QR codes.}

  spec.homepage      = "https://github.com/IPGPTP/live_paper_rubygem"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rest-client"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "codeclimate-test-reporter"
end
