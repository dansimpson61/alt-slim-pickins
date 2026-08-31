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
