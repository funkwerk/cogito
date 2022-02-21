#!/usr/bin/env ruby
# frozen_string_literal: true
#
require 'pathname'

BINARY = 'build/cogito'
ARGUMENTS = [
  "-of=#{BINARY}",
  '-I=src',
  '-I=tools/dmd2/src/dmd',
  'src/cogito/visitor.d',
  'src/main.d',
  'build/dmd.a'
]

def make_arguments(name, arguments)
  arguments.map do |argument|
    "-#{name}=#{argument}"
  end
end

def frontend_arguments
  versions = make_arguments 'version', ['MARS', 'NoMain']
  string_imports = make_arguments 'J', ['.', './tools/dmd2/src/dmd/dmd/res']

  arguments = versions + string_imports
  arguments << '-od=build'
end

def build_frontend(version = 'debug')
  frontend_includes = Dir.glob('./tools/dmd2/src/dmd/dmd/**/*.d').to_a
  frontend_includes = Dir.glob('/usr/include/dmd/dmd/**/*.d').to_a
  arguments = frontend_arguments +
    ['-I=tools/dmd2/src/dmd', '-of=dmd.a'] +
    frontend_includes

  Dir.mkdir 'build' unless Dir.exist? 'build'

  system('dmd', "-#{version}", '-lib', *arguments, exception: true)
end

def build(version = 'debug')
  arguments = frontend_arguments + ARGUMENTS

  Dir.mkdir 'build' unless Dir.exist? 'build'

  system('dmd', "-#{version}", *arguments, exception: true)
end

def build_tests
  arguments = frontend_arguments + ARGUMENTS

  Dir.mkdir 'build' unless Dir.exist? 'build'

  system('dmd', '-unittest', *arguments, exception: true)
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
  build_tests
  system BINARY, 'sample/sample.d'
when 'ts'
  system('npx', 'cognitive-complexity-ts-json', 'sample/sample.ts')
else
  raise "Command „#{ARGV[0]}“ doesn't exist"
end
