#!/usr/bin/env ruby

frontend_includes = Dir.glob('/usr/include/dmd/dmd/**/*.d').to_a
versions = ['MARS', 'NoMain'].map { |version| "-version=#{version}" }

arguments = versions + ['-of=main'] + frontend_includes
arguments << 'main.d'

system('dmd', '-J=.', '-J=/usr/include/dmd/dmd/res', *arguments)
