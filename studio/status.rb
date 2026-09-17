# frozen_string_literal: true

require 'timeout'

# The checkers' output, captured live, for the studio's status page.
#
# The checkers are root scripts that print and exit — they are the one home
# of each fact they print, so the page runs them rather than re-deriving
# anything. Each leg is run fresh on every visit: a status page that
# remembered its verdict could claim green while red, and the whole point
# of the page is that it cannot.
module StudioStatus
  ROOT = File.expand_path('..', __dir__)

  # The gate's legs, in the order the gate runs them. Promises, Conventions and
  # Card are the instruments DAYTRIP-0.3.0b landed — they are gate legs because
  # an instrument nothing runs is not an instrument.
  LEGS = [
    ['Grammar', 'check_grammar.rb'],
    ['Shape', 'check_shape.rb'],
    ['Styles', 'check_styles.rb'],
    ['Promises', 'bin/check_promises.rb'],
    ['Conventions', 'bin/check_conventions.rb'],
    ['Card', 'bin/check_card.rb'],
    ['Pages', 'bin/verify_pages.rb'],
  ].freeze

  SECONDS = 60

  Result = Struct.new(:name, :output, :ok, keyword_init: true) do
    # The page renders each leg's output through prose, in a fence — the
    # language's own code-block form, grown in this same phase.
    def fenced = "```text\n#{output}```"

    # The leg's state, as data: the page says `badge .state`, never a
    # conditional, and the stylesheet draws the mark off that class.
    def state = ok ? 'ok' : 'error'
  end

  def self.run
    LEGS.map do |name, script|
      output = nil
      ok = Timeout.timeout(SECONDS) do
        output = Dir.chdir(ROOT) { IO.popen(['ruby', script], err: %i[child out], &:read) }
        $?.success?
      end
      Result.new(name: name, output: output || '', ok: ok)
    rescue Timeout::Error
      Result.new(name: name, output: "(no verdict — timed out after #{SECONDS}s)", ok: false)
    end
  end

  def self.overview(results)
    bad = results.count { |r| !r.ok }
    when_run = Time.now.strftime('%Y-%m-%d %H:%M')
    bad.zero? ? "All #{results.size} legs green, run live at #{when_run}." \
              : "#{bad} of #{results.size} legs red, run live at #{when_run}."
  end

  # The canned shape, for proving this page without recursing: its route shells
  # this very gate, so live results would run the gate inside the gate. One home
  # for it, because `bin/verify_pages.rb` and `studio_docs_test` each kept their
  # own copy and the two would drift the moment a leg was added — which two legs
  # just were. One leg is red on purpose: a page that cannot render a red leg
  # cannot report one.
  def self.canned
    LEGS.map.with_index do |(name, _script), index|
      Result.new(name: name, output: index == 1 ? "1 problem\n" : "0 problems\n", ok: index != 1)
    end
  end

  def self.canned_locals = { results: canned, overview: overview(canned) }
end
