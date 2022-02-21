#!/usr/bin/env ruby
# frozen_string_literal: true
#
require 'pathname'

BINARY = 'build/cogito'
ARGUMENTS = [
  "-of=#{BINARY}",
  '-I=src',
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
  string_imports = make_arguments 'J', ['.', '/usr/include/dmd/dmd/res']

  arguments = versions + string_imports
  arguments << '-od=build'
end

def build_frontend
  frontend_includes = Dir.glob('/usr/include/dmd/dmd/**/*.d').to_a
  arguments = frontend_arguments + ['-of=dmd.a'] + frontend_includes

  Dir.mkdir 'build' unless Dir.exist? 'build'

  system('dmd', '-debug', '-lib', *arguments, exception: true)
end

def build
  arguments = frontend_arguments + ARGUMENTS

  Dir.mkdir 'build' unless Dir.exist? 'build'

  system('dmd', '-debug', *arguments, exception: true)
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
