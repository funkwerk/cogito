#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

BIN_PATH = Pathname.new 'tools/dmd2/linux/bin64'
BINARY = 'build/cogito'

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
  arguments = frontend_arguments + Dir.glob('src/**/*.d') + [
    "-of=#{BINARY}",
    '-I=src',
    '-I=tools/dmd2/src/dmd',
    'build/dmd.a'
  ]

  Dir.mkdir 'build' unless Dir.exist? 'build'

  system('dmd', "-#{version}", *arguments, exception: true)
end

def test
  build_frontend unless File.exist? 'build/dmd.a'

  system((BIN_PATH + 'dub').to_s, 'build', '--build=unittest', exception: true)
  system 'build/test', '-s'
end

case ARGV.fetch(0, 'd')
when 'd'
  build_frontend
  build
when 'release'
  build_frontend 'release'
  build 'release'
when 'run'
  build
  system BINARY, 'sample/sample.d'
when 'test'
  test
when 'ts'
  system('npx', 'cognitive-complexity-ts-json', 'sample/sample.ts')
else
  raise "Command „#{ARGV[0]}“ doesn't exist"
end

exit $?.exitstatus
