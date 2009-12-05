# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rbankgiro}
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Johan Eckerstr\303\266m"]
  s.date = %q{2009-12-06}
  s.description = %q{Parsing transaction files from swedish Bankgiro central}
  s.email = %q{johan@duh.se}
  s.extra_rdoc_files = [
    "LICENSE"
  ]
  s.files = [
    "LICENSE",
     "Rakefile",
     "VERSION",
     "lib/rbankgiro.rb",
     "rbankgiro.gemspec",
     "test/fixtures/corrupt_header_09_02_27.txt",
     "test/fixtures/file_format_error_09_02_27.txt",
     "test/fixtures/missing_transaction_09_02_27.txt",
     "test/fixtures/one_too_many_transactions_09_02_27.txt",
     "test/fixtures/one_transaction_09_02_27.txt",
     "test/helper.rb",
     "test/test_transaction.rb",
     "test/test_transactions.rb"
  ]
  s.homepage = %q{http://github.com/jage/rbankgiro}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Parse Bankgiro transaction files}
  s.test_files = [
    "test/helper.rb",
     "test/test_transaction.rb",
     "test/test_transactions.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

