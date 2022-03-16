#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'fileutils'

BIN_PATH = Pathname.new 'tools/dmd2/linux/bin64'

def make_arguments(name, arguments)
  arguments.map do |argument|
    "-#{name}=#{argument}"
  end
end

def frontend_arguments
  versions = make_arguments 'version', ['MARS', 'NoMain']
  string_imports = make_arguments 'J', ['./include', './tools/dmd2/src/dmd/dmd/res']

  arguments = versions + string_imports
  arguments << '-od=build'
end

def build_frontend(version = 'debug')
  frontend_includes = Dir.glob('./tools/dmd2/src/dmd/dmd/**/*.d').to_a
  arguments = frontend_arguments +
    ['-I=tools/dmd2/src/dmd', '-of=dmd.a'] +
    frontend_includes

  Dir.mkdir 'build' unless Dir.exist? 'build'

  system('dmd', "-#{version}", '-lib', *arguments, exception: true)
end

def build(version = 'debug')
  build_frontend unless File.exist? 'build/dmd.a'
  config = version == 'unittest' ? 'unittest' : 'executable'

  p (BIN_PATH + 'dub').to_s
  system((BIN_PATH + 'dub').to_s,
    'build', "--build=#{version}",
    "--config=#{config}",
    exception: true)
end

def clean
  FileUtils.rm_f Dir.glob('build/*')

  system((BIN_PATH + 'dub').to_s, 'clean', exception: true)
end

case ARGV.fetch(0, 'd')
when 'd'
  clean
  build
when 'release'
  build 'release'
when 'run'
  build 'debug'
  system 'build/cogito', 'sample/sample.d'
when 'test'
  build 'unittest'
  system 'build/test', '-s'
when 'ts'
  system('npx', 'cognitive-complexity-ts-json', 'sample/sample.ts')
else
  raise "Command „#{ARGV[0]}“ doesn't exist"
end

exit $?.exitstatus
