# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'
require_relative '../examples/dashboard/words/dashboard_words'

# The exam's first page, held to the inventory: what the original /triage
# could do, the port must do — every affordance, nothing vanished.
class DashboardTest < Minitest::Test
  VIEWS = File.expand_path('../examples/dashboard/views', __dir__)

  NAV = { studio: false, library: false, reconcile: false, dispatch: false,
          ports: false }.freeze

  def library
    @library ||= SlimPickins::Library.from(VIEWS, words: DashboardWords)
  end

  def render_triage(locals)
    SlimPickins.render(File.read(File.join(VIEWS, 'triage.sp')), path: 'triage.sp',
                       locals: { notice: nil, search_q: '', error_entry: nil, nav: NAV,
                                 unreviewed: 0 }.merge(locals),
                       library: library)
  end

  def queue_item(overrides = {})
    { path: 'ode-to-joy', status: 'active', stale_days: 3, purpose: 'The credo',
      next_step: 'Rewrite Part V', dirty: true, zero_commits: false }.merge(overrides)
  end

  def test_the_queue_names_its_count_and_renders_the_first_card
    html = render_triage(queue: [queue_item, queue_item(path: 'abide', status: 'dormant',
                                                        stale_days: nil, purpose: 'Habit tracker',
                                                        next_step: '-', dirty: false,
                                                        zero_commits: true)])
    assert_includes html, '2 item(s) need attention — this is the first:'
    assert_includes html, '<article class="sp-card">'
    assert_includes html, '<h3 class="sp-card__title">ode-to-joy</h3>'
    assert_includes html, '<span class="sp-badge sp-badge--ok">active</span>'
    assert_includes html, 'stale 3d'
    assert_includes html, 'The credo'
    assert_includes html, '<p class="sp-text-strong">Next: Rewrite Part V</p>'
    refute_includes html, 'abide' # only the first item renders
  end

  def test_the_four_action_forms_carry_the_original_hidden_inputs
    html = render_triage(queue: [queue_item])
    assert_includes html, '<form method="post" action="/actions/commit">'
    assert_includes html, '<input type="hidden" name="path" value="ode-to-joy">'
    assert_includes html, '<input type="hidden" name="return_to" value="/triage">'
    assert_includes html, '<form method="post" action="/actions/status">'
    assert_includes html, '<input type="hidden" name="status" value="dormant">'
    assert_includes html, '<form method="post" action="/actions/archive">'
    assert_includes html, '<form method="post" action="/actions/skip">'
    ['Commit', 'Set dormant', 'Archive', 'Skip 30d'].each { |l| assert_includes html, l }
  end

  def test_commit_appears_only_when_dirty_or_zero_commits
    clean = render_triage(queue: [queue_item(dirty: false, zero_commits: false)])
    refute_includes clean, 'action="/actions/commit"'
    zero = render_triage(queue: [queue_item(dirty: false, zero_commits: true)])
    assert_includes zero, 'action="/actions/commit"'
  end

  def test_next_line_is_quiet_when_the_step_is_a_dash
    html = render_triage(queue: [queue_item(next_step: '-')])
    refute_includes html, 'sp-text-strong'
  end

  def test_never_committed_when_there_are_no_stale_days
    html = render_triage(queue: [queue_item(stale_days: nil)])
    assert_includes html, 'never committed'
  end

  def test_an_empty_queue_is_a_quiet_sentence
    html = render_triage(queue: [])
    assert_includes html, 'All caught up. Nothing needs attention.'
    refute_includes html, 'sp-card__title'
  end

  def test_the_unreviewed_card_is_plural_aware_and_absent_at_zero
    html = render_triage(queue: [], unreviewed: 3)
    assert_includes html, '3 instruction files awaiting judgment'
    assert_includes html, 'href="/dispatch">Review on Dispatch'
    absent = render_triage(queue: [], unreviewed: 0)
    refute_includes absent, 'awaiting judgment'
  end

  def test_the_notice_flash_renders_only_when_there_is_one
    assert_includes render_triage(queue: [], notice: 'Saved.'), 'sp-flash sp-flash--notice'
    refute_includes render_triage(queue: []), 'sp-flash'
  end

  def test_the_layout_puts_nav_shell_and_search_around_the_page
    html = render_triage(queue: [])
    assert_includes html, 'sp-nav-brand'
    assert_includes html, 'sp-nav-search'
    assert_includes html, '<div class="sp-page sp-page--wide">'
    assert_includes html, 'placeholder="search…"'
    refute_includes html, 'sp-nav-link--here' # /triage activates no nav link
  end

  def test_confirm_archive_carries_the_reason_and_the_hidden_confirm
    html = SlimPickins.render(File.read(File.join(VIEWS, 'confirm_archive.sp')),
                              path: 'confirm_archive.sp',
                              locals: { archive_heading: 'Archive "abide"?', archive_path: 'abide',
                                        archive_reference: nil, archive_return_to: '/triage',
                                        archive_reason: '', notice: nil, search_q: '',
                                        error_entry: nil, nav: NAV },
                              library: library)
    assert_includes html, '<h1>Archive &quot;abide&quot;?</h1>'
    assert_includes html, '<input type="hidden" name="confirmed" value="1">'
    assert_includes html, '<textarea class="sp-input" id="reason" name="reason" rows="2" required="required"></textarea>'
    assert_includes html, 'Confirm archive'
    assert_includes html, 'Cancel'
  end
end
