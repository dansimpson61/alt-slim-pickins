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

  # The gate's four legs, in the order the gate runs them.
  LEGS = [
    ['Grammar', 'check_grammar.rb'],
    ['Shape', 'check_shape.rb'],
    ['Styles', 'check_styles.rb'],
    ['Pages', 'bin/verify_pages.rb'],
  ].freeze

  SECONDS = 60

  Result = Struct.new(:name, :output, :ok, keyword_init: true) do
    # The page renders each leg's output through prose, in a fence — the
    # language's own code-block form, grown in this same phase.
    def fenced = "```text\n#{output}```"

    # The leg's state, as data: the page says `icon .state` and
    # `badge .state`, never a conditional. The icon is decorative by
    # contract, so the badge is what a screen reader hears.
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
end
