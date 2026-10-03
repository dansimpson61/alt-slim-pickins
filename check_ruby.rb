#!/usr/bin/env ruby
# frozen_string_literal: true
#
# The twelfth checker: the Ruby reads the way the house writes it.
#
# DAYTRIP-0.4.0h's Part 3 found thirteen `def`s at column 0 while every sibling
# sat at 4 or 6, seven further indentation regimes *inside* method bodies that a
# `def`-line scan cannot see, a method defined twice with Ruby silently taking
# the second, and four assignments nothing read. They had been there a month, in
# a project with ten gates. Part 4 explained why: eight of those ten compare a
# declaration to a declaration, and none of them read the Ruby as text. There is
# no RuboCop config either.
#
# `ruby -w -c` reports every one of those, in the interpreter the project
# already runs, with no gem and no new dependency:
#
#   generator.rb:180: warning: mismatched indentations at 'ensure' with 'def' at 152
#
# A warning is a failure here rather than a note. That is the whole point — the
# defects above were all warnings nobody was listening for.
#
# Two things about the mechanism were measured rather than assumed, because both
# obvious shortcuts are wrong:
#
#   - **One file per process.** `ruby -c a.rb b.rb` checks only `a.rb` and
#     prints one cheerful `Syntax OK`. Over this repository that reads the first
#     file and silently skips a hundred others.
#   - **A subprocess, not the parser in-process.** Overriding `Warning.warn`
#     around `RubyVM::InstructionSequence.compile` is faster and catches the
#     dead locals, but it does *not* emit the mismatched-indentation warnings —
#     the ones that found the defects this gate exists for. The cheap version
#     would pass a file this one refuses.
#
# The cost of being right about that is a process per file, which is under a
# second over the whole tree.
#
# Exits non-zero on any warning, so it can gate a commit.

module RubyShape
  ROOT = __dir__

  Finding = Struct.new(:file, :line, :kind, :message, keyword_init: true)

  # `path:12: warning: the thing it noticed` — the path is already known, so
  # only the line and the sentence are kept.
  REPORT = /\A.*?:(\d+):\s*(?:warning:\s*)?(.*)\z/m

  module_function

  # Every Ruby file the project owns: the runtime, the studio, the gates
  # themselves, the suite, and the example apps' domain code.
  def all_files
    (Dir[File.join(ROOT, '{lib,bin,studio,test,examples}', '**', '*.rb')] +
      Dir[File.join(ROOT, 'check_*.rb')]).sort
  end

  # `ruby -w -c` exits 0 for a file whose syntax is fine however much it warns,
  # so the verdict is read from what it said, not from how it left.
  def findings_in(path)
    relative = path.delete_prefix("#{ROOT}/")
    output = IO.popen(['ruby', '-w', '-c', path], err: %i[child out], &:read).to_s
    syntax_ok = output.lines.any? { |line| line.chomp == 'Syntax OK' }

    kind = syntax_ok ? 'WARNING' : 'WILL NOT PARSE'
    output.lines.map(&:chomp).reject { |line| line.empty? || line == 'Syntax OK' }.map do |line|
      number, message = line.match(REPORT)&.captures
      Finding.new(file: relative, line: number, message: message || line.strip, kind: kind)
    end
  end

  def run(files: nil, out: $stdout)
    files ||= all_files
    findings = files.flat_map { |path| findings_in(path) }

    findings.each do |finding|
      where = finding.line ? "#{finding.file}:#{finding.line}" : finding.file
      out.puts "  #{finding.kind.ljust(14)} #{where} #{finding.message}"
    end

    out.puts
    out.puts "ruby -w -c over #{files.size} files — the interpreter the project already runs, and no gem"
    out.puts
    out.puts "#{findings.size} problems"
    findings.size
  end
end

exit(RubyShape.run.zero? ? 0 : 1) if $PROGRAM_NAME == __FILE__
