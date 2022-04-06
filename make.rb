#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'fileutils'
require 'net/http'

DC = Pathname.new(ENV.fetch 'DC', 'tools/dmd2/linux/bin64/dmd').expand_path
BIN_PATH = DC.dirname

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

def fetch_frontend(raw_uri, target)
  uri = URI raw_uri

  Net::HTTP.start uri.host, uri.port, use_ssl: uri.scheme == 'https' do |http|
    request = Net::HTTP::Get.new uri

    http.request request do |response|
      case response
      when Net::HTTPSuccess
        File.open target, 'w' do |io|
          response.read_body do |chunk|
            io << chunk
          end
        end
      when Net::HTTPRedirection
        fetch_frontend response['location'], target
      end
    end
  end
end

def install_frontend
  FileUtils.rm_rf './tools/dmd2'

  dmd_version = File.read('include/VERSION').strip[1..]
  filename = "dmd.#{dmd_version}.linux.zip"
  target = "./tools/#{filename}"
  fetch_frontend "http://downloads.dlang.org/releases/2.x/#{dmd_version}/#{filename}", target
  system 'unzip', '-d', 'tools', target, exception: true

  dmd_version
end

def build_frontend(version = 'debug')
  frontend_includes = Dir.glob('./tools/dmd2/src/dmd/dmd/**/*.d').to_a
  arguments = frontend_arguments +
    ['-I=tools/dmd2/src/dmd', '-of=dmd.a'] +
    frontend_includes

  Dir.mkdir 'build' unless Dir.exist? 'build'

  system(DC.to_s,
    "-#{version}",
    '-lib',
    *arguments,
    exception: true)
end

def dub(command, arguments = [])
  system({ 'DC' => DC.to_s },
    (BIN_PATH + 'dub').to_s,
    command, *arguments,
    exception: true)
end

def build(version = 'debug')
  build_frontend unless File.exist? 'build/dmd.a'
  config = version == 'unittest' ? 'unittest' : 'executable'

  dub 'build', ["--build=#{version}", "--config=#{config}"]
end

def clean
  FileUtils.rm_f Dir.glob('build/*')
  dub 'clean'
end

(ARGV.empty? ? ['run'] : ARGV).each do |argument|
  case argument
  when 'clean'
    clean
  when 'release', 'debug'
    build argument
  when 'run'
    build 'debug'
    system 'build/cogito', '--format', 'verbose', 'tools/sample.d'
  when 'test'
    build 'unittest'
    system 'build/test', '-s'
  when 'install'
    install_frontend
  else
    puts <<~CMD
      Command „#{argument}“ doesn't exist.
      Available commands are: clean, release, debug, unittest, install.
    CMD
    exit 1
  end
end

exit $?.exitstatus unless $?.nil?
