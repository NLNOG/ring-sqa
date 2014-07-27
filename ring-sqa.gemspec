Gem::Specification.new do |s|
  s.name              = 'ring-sqa'
  s.version           = '0.0.21'
  s.licenses          = %w( Apache-2.0 )
  s.platform          = Gem::Platform::RUBY
  s.authors           = [ 'Saku Ytti', 'Job Snijders' ]
  s.email             = %w( saku@ytti.fi )
  s.homepage          = 'http://github.com/ytti/ring-sqa'
  s.summary           = 'NLNOG Ring SQA'
  s.description       = 'gets list of nodes and pings from each to each storing results'
  s.rubyforge_project = s.name
  s.files             = `git ls-files`.split("\n")
  s.executables       = %w( ring-sqad )
  s.require_path      = 'lib'

  s.required_ruby_version = '>= 1.9.3'
  s.add_runtime_dependency 'slop',       '~> 3.5'
  s.add_runtime_dependency 'rb-inotify', '~> 0.9'
  s.add_runtime_dependency 'sequel',     '~> 4.12'
  s.add_runtime_dependency 'sqlite3',    '~> 1.3'
  s.add_runtime_dependency 'asetus',     '~> 0.1', '>= 0.1.2'
end
