# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# The re-authored triage: the page says mechanical facts; the app computes
# every judgement (stale text, the commit offer, the plural sentence) and
# the page just presents them. These tests hold the interface — the shape of
# the decorated queue — and every affordance the original could do.
class DashboardTest < Minitest::Test
  VIEWS = File.expand_path('../examples/dashboard/views', __dir__)

  NAV = { studio: false, library: false, reconcile: false, dispatch: false,
          ports: false }.freeze

  def library
    @library ||= SlimPickins::Library.from(VIEWS)
  end

  def render_triage(locals)
    SlimPickins.render(File.read(File.join(VIEWS, 'triage.sp')), path: 'triage.sp',
                       locals: { notice: nil, q: '', error_entry: nil, nav_state: NAV,
                                 unreviewed: nil, first_item: nil, queue_intro: '' }.merge(locals),
                       library: library)
  end

  # What the app's decorate() makes of a project — the judgement, computed.
  def item(overrides = {})
    { path: 'ode-to-joy', status: 'active', status_variant: :ok,
      stale_text: 'stale 3d', purpose: 'The credo', next_line: 'Next: Rewrite Part V',
      offer_commit: true }.merge(overrides)
  end

  def test_the_queue_names_its_count_and_renders_the_first_card
    html = render_triage(first_item: item, queue_intro: '2 item(s) need attention — this is the first:')
    assert_includes html, '2 item(s) need attention — this is the first:'
    assert_includes html, '<article class="card">'
    assert_includes html, '<h2 class="card card--title">ode-to-joy</h2>'
    assert_includes html, '<span class="badge badge--ok">active</span>'
    assert_includes html, 'The credo'
    assert_includes html, 'Next: Rewrite Part V'
  end

  def test_the_four_actions_post_the_original_payloads
    html = render_triage(first_item: item, queue_intro: '1 item(s) need attention — this is the first:')
    assert_includes html, '<form action="/actions/commit" method="post">'
    assert_includes html, '<form action="/actions/status" method="post">'
    assert_includes html, '<form action="/actions/archive" method="post">'
    assert_includes html, '<form action="/actions/skip" method="post">'
    assert_includes html, '<input type="hidden" name="path" value="ode-to-joy">'
    assert_includes html, '<input type="hidden" name="return_to" value="/triage">'
    assert_includes html, '<input type="hidden" name="status" value="dormant">'
    ['Commit', 'Set dormant', 'Archive', 'Skip 30d'].each { |l| assert_includes html, l }
  end

  def test_commit_is_offered_only_when_the_app_offers_it
    quiet = render_triage(first_item: item(offer_commit: false), queue_intro: '')
    refute_includes quiet, 'action="/actions/commit"'
    assert_includes render_triage(first_item: item(offer_commit: true), queue_intro: ''),
                    'action="/actions/commit"'
  end

  def test_the_next_line_is_quiet_when_the_app_says_nothing
    html = render_triage(first_item: item(next_line: nil), queue_intro: '')
    refute_includes html, 'Next:'
  end

  def test_an_empty_queue_is_a_quiet_sentence
    html = render_triage(first_item: nil, queue_intro: '')
    assert_includes html, 'All caught up. Nothing needs attention.'
    refute_includes html, 'card--title'
  end

  def test_the_unreviewed_card_renders_the_apps_sentence
    html = render_triage(unreviewed: '3 instruction files awaiting judgment — hand-kept rules nobody has ruled canonical or legacy.')
    assert_includes html, '3 instruction files awaiting judgment'
    assert_includes html, 'Review on Dispatch'
    refute_includes render_triage(first_item: nil, queue_intro: ''), 'awaiting judgment'
  end

  def test_the_notice_flash_renders_only_when_there_is_one
    assert_includes render_triage(notice: 'Saved.'), '<p class="note">Saved.</p>'
    refute_includes render_triage(first_item: nil, queue_intro: ''), 'class="note"'
  end

  def test_the_layout_puts_nav_search_and_an_active_free_bar_around_the_page
    html = render_triage(first_item: nil, queue_intro: '')
    assert_includes html, 'class="nav"'
    assert_includes html, 'placeholder="search…"'
    refute_includes html, 'link--active' # /triage activates no nav link
  end

  def test_confirm_archive_carries_the_reason_and_the_hidden_confirm
    html = SlimPickins.render(File.read(File.join(VIEWS, 'confirm_archive.sp')),
                              path: 'confirm_archive.sp',
                              locals: { archive_heading: 'Archive "abide"?', archive_path: 'abide',
                                        archive_return_to: '/triage', reason: '',
                                        notice: nil, q: '', error_entry: nil, nav_state: NAV },
                              library: library)
    assert_includes html, '<h1>Archive &quot;abide&quot;?</h1>'
    assert_includes html, '<input type="hidden" name="confirmed" value="1">'
    assert_includes html, '<textarea id="reason" name="reason" rows="2" required="required"></textarea>'
    assert_includes html, 'Confirm archive'
    assert_includes html, 'Cancel'
  end
end
