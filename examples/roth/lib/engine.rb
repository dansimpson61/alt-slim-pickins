# frozen_string_literal: true

# roth's engine, required off disk and otherwise untouched.
#
# `~/dev/roth` is a separate, dormant project with a dirty working tree and a
# domain backlog of its own (ROTH_DOMAIN_BACKLOG.md). This port changes its
# views and its architecture, never its arithmetic — so the numbers on the page
# are roth's numbers, defects included, and the page says so.
#
# The one addition is the `require` roth is missing: `Projector` builds
# OpenStructs and nothing there requires `ostruct`. roth's own app survives on a
# transitive require from Sinatra; its specs do not, which is why they have
# never run.

require 'ostruct'

ENGINE = File.expand_path('~/dev/roth/lib/engine')

require File.join(ENGINE, 'inputs')
require File.join(ENGINE, 'projector')
require File.join(ENGINE, 'tax_tables')
require File.join(ENGINE, 'strategy/fixed_amount')
require File.join(ENGINE, 'strategy/fill_bracket')

# This port reads the engine as it stands in roth's *working tree*, which has
# been mid-rename since 2025-09-11: `social_security_*` became `ss_primary_*`
# in `inputs.rb` and `projector.rb` and nowhere else. `Scenario` speaks the new
# spelling, so finishing that rename keeps this working and reverting it breaks
# this — and the break would otherwise surface as a wrong number rather than an
# error, which is the whole failure mode being ported away from.
EXPECTED = %i[ss_primary_start_year ss_primary_amount].freeze
missing = EXPECTED - Engine::Inputs.members

unless missing.empty?
  raise "~/dev/roth's engine no longer has #{missing.join(', ')}. " \
        'The abandoned rename there was reverted rather than finished — see ' \
        "ROTH_DOMAIN_BACKLOG.md §0.2. Scenario#to_engine_inputs is the one " \
        'place that needs the other spelling.'
end
