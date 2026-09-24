# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# Phase 2: collections, the table that writes no loop, and formatting.
class Phase2Test < Minitest::Test
  Holding = Struct.new(:symbol, :shares, :market_value, keyword_init: true) do
    FORMATS = { shares: :number, market_value: :money }.freeze
    def format_for(attribute) = FORMATS[attribute]
  end
  Plain = Struct.new(:symbol, :market_value, keyword_init: true)
  Account = Struct.new(:name, :holdings, keyword_init: true)
  Book = Struct.new(:entries, keyword_init: true)

  def render(source, **locals)
    SlimPickins.render(source, path: '(test)', locals: locals)
  end

  def portfolio(*accounts) = { accounts: accounts }

  def two_accounts
    portfolio(
      Account.new(name: 'Traditional', holdings: [
                    Holding.new(symbol: 'VTI', shares: 1240, market_value: 356_120),
                    Holding.new(symbol: 'VXUS', shares: 890, market_value: 61_410)
                  ]),
      Account.new(name: 'Roth', holdings: [Holding.new(symbol: 'VTI', shares: 410, market_value: 117_760)])
    )
  end

  # --- collections and nesting ----------------------------------------

  def test_each_finds_the_collection_by_pluralising_the_name
    html = render("page book\n  each entry\n    title .name\n",
                  book: Book.new(entries: [{ name: 'One' }, { name: 'Two' }]))
    assert_includes html, '<h2 class="title">One</h2>'
    assert_includes html, '<h2 class="title">Two</h2>'
  end

  def test_pluralising_handles_the_y_case
    assert_equal 'entries', SlimPickins::Inference.plural(:entry)
    assert_equal 'holdings', SlimPickins::Inference.plural(:holding)
    assert_equal 'days', SlimPickins::Inference.plural(:day)
  end

  # Under `section accounts` the subject *is* the collection, which is what
  # lets `empty` know what is empty. `each` iterates it rather than looking
  # for `accounts` on an array.
  def test_each_iterates_the_subject_when_the_subject_is_the_collection
    html = render("page portfolio\n  section accounts\n    each account\n      title .name\n",
                  portfolio: two_accounts)
    assert_includes html, '<h3 class="title">Traditional</h3>'
    assert_includes html, '<h3 class="title">Roth</h3>'
  end

  def test_from_overrides_pluralising
    html = render("page book\n  each entry, from: .recent\n    title .name\n",
                  book: { recent: [{ name: 'Only' }] })
    assert_includes html, '<h2 class="title">Only</h2>'
  end

  def test_a_collection_that_is_not_there_says_so
    error = assert_raises(SlimPickins::Error) do
      render("page book\n  each entry\n    title .name\n", book: { other: [] })
    end
    assert_match(/\Athis book has no entries to go through\n/, error.message)
  end

  def test_a_non_collection_attribute_refuses_honestly
    error = assert_raises(SlimPickins::Error) do
      render("page book\n  each entry\n    title .name\n", book: { entries: 'not a collection' })
    end
    assert_match(/this book's entries is not a collection to go through/, error.message)
  end

  def test_each_from_non_collection_refuses_honestly
    error = assert_raises(SlimPickins::Error) do
      render("page book\n  each entry, from: .count\n    title .name\n", book: { count: 42 })
    end
    assert_match(/`each entry` expects a collection to go through, got integer/, error.message)
  end

  # --- three levels, through the language this time --------------------

  def test_collections_nest_and_reaching_out_by_name_still_works
    html = render(<<~PAGE, portfolio: two_accounts)
      page portfolio
        section accounts
          each account
            each holding
              title account.name
              title .symbol
    PAGE
    assert_includes html, '<h3 class="title">Traditional</h3>'
    assert_includes html, '<h3 class="title">VTI</h3>'
    assert_includes html, '<h3 class="title">VXUS</h3>'
  end

  # --- the table writes no loop ----------------------------------------

  def test_a_table_declares_columns_and_the_rows_come_from_the_subject
    roth = Account.new(name: 'Roth', holdings: [
                         Holding.new(symbol: 'VTI', shares: 410, market_value: 117_760)
                       ])
    html = render(<<~PAGE, account: roth)
      page account
        table holdings
          column symbol
          column market_value, "Value"
    PAGE
    assert_includes html, '<th>Symbol</th>'
    assert_includes html, '<th class="column--numeric">Value</th>'
    assert_includes html, '<td>VTI</td>'
    assert_includes html, '<td class="column--numeric">$117,760</td>'
  end

  def test_total_sums_the_column_over_the_collection
    html = render(<<~PAGE, account: two_accounts[:accounts].first)
      page account
        table holdings
          column symbol
          column market_value
          total market_value, "Account total"
    PAGE
    assert_includes html, '<tfoot>'
    assert_includes html, '>Account total<'
    assert_includes html, '$417,530'   # 356,120 + 61,410
  end

  def test_column_outside_a_table_says_where_it_belongs
    error = assert_raises(SlimPickins::Error) { render("page book\n  column name\n", book: {}) }
    assert_match(/\A`column` belongs inside `table`\n/, error.message)
  end

  # --- empty names a situation, it does not write a branch --------------

  def test_empty_renders_and_suppresses_its_siblings_when_there_is_nothing
    html = render(<<~PAGE, portfolio: portfolio)
      page portfolio
        section accounts
          empty "No accounts linked yet."
          each account
            title .name
    PAGE
    assert_includes html, '<p class="empty">No accounts linked yet.</p>'
  end

  def test_empty_renders_nothing_when_there_is_something
    html = render(<<~PAGE, portfolio: two_accounts)
      page portfolio
        section accounts
          empty "No accounts linked yet."
          each account
            title .name
    PAGE
    refute_includes html, 'No accounts linked yet.'
    assert_includes html, '<h3 class="title">Traditional</h3>'
  end

  # --- formatting -------------------------------------------------------

  def test_money_percent_and_number_format_from_the_value
    assert_equal '$1,284,506', SlimPickins::Inference.money(1_284_506)
    assert_equal '−$3,180', SlimPickins::Inference.money(-3180)
    assert_equal '7.4%', SlimPickins::Inference.percent(0.0742)
    assert_equal '1,240', SlimPickins::Inference.number(1240)
  end

  def test_a_negative_amount_is_classed_so_red_is_css_s_job
    html = render("page book\n  money .loss\n", book: { loss: -12 })
    assert_includes html, 'class="money money--negative"'
  end

  # The whole point: shape says number, the app says money.
  def test_the_app_answers_what_shape_cannot_and_the_page_says_nothing
    html = render(<<~PAGE, account: two_accounts[:accounts].last)
      page account
        table holdings
          column market_value
    PAGE
    assert_includes html, '$117,760'
  end

  def test_without_format_for_a_number_is_still_right_aligned
    plain = Account.new(name: 'x', holdings: [Plain.new(symbol: 'A', market_value: 5)])
    html = render(<<~PAGE, account: plain)
      page account
        table holdings
          column market_value
    PAGE
    assert_includes html, '<td class="column--numeric">5</td>'
  end

  def test_the_page_still_overrides_the_app
    html = render(<<~PAGE, account: two_accounts[:accounts].last)
      page account
        table holdings
          column market_value, as: number
    PAGE
    assert_includes html, '<td class="column--numeric">117,760</td>'
  end

  # --- title infers its level from depth --------------------------------

  def test_a_title_knows_how_deep_it_is
    html = render(%(page book\n  title "Top"\n  section "Part"\n    title "Inner"\n), book: {})
    assert_includes html, '<h2 class="title">Top</h2>'
    assert_includes html, '<h3 class="title">Inner</h3>'
  end

  # --- a name is a subject; content is a label --------------------------

  # The two jobs have two spellings, so which one a section is doing is
  # visible in the page rather than dependent on what the data happens to
  # hold. `section "Allocation"` cannot start shifting the subject because
  # someone later adds an `allocation` attribute.
  def test_a_section_named_with_content_is_a_label_and_shifts_nothing
    html = render(%(page portfolio\n  section "Where you stand"\n    title .heading\n),
                  portfolio: { heading: 'Still the portfolio' })
    assert_includes html, '<h2 class="section-title">Where you stand</h2>'
    assert_includes html, '<h3 class="title">Still the portfolio</h3>'
  end

  def test_a_section_named_with_a_name_shifts_the_subject
    html = render("page portfolio\n  section accounts\n    each account\n      title .name\n",
                  portfolio: two_accounts)
    assert_includes html, '<h3 class="title">Traditional</h3>'
  end

  def test_a_section_naming_a_subject_that_is_absent_fails_on_its_own_line
    error = assert_raises(SlimPickins::UnknownAttribute) do
      render("page portfolio\n  section summary\n    title .x\n", portfolio: { x: 1 })
    end
    assert_match(/\Athis portfolio has no summary\n  \(test\), line 2\n    section summary\z/, error.message)
  end

  # --- unknown words ----------------------------------------------------

  def test_an_unknown_word_fails_with_its_own_name
    error = assert_raises(SlimPickins::Error) { render(%(page book\n  sparkline "x"\n), book: {}) }
    assert_match(/\Athere is no word `sparkline`\n/, error.message)
  end

  # Ruby evaluates arguments before the call, so an unknown word carrying a
  # bad argument reports the argument first. Both messages are true and name
  # a real problem; this one just names the inner one.
  def test_an_unknown_word_with_a_bad_argument_reports_the_argument_first
    error = assert_raises(SlimPickins::Error) { render("page book\n  sparkline .x\n", book: {}) }
    assert_match(/\Athis book has no x\n/, error.message)
  end
end
