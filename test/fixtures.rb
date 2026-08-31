# frozen_string_literal: true

require 'date'

# The objects the repo's own pages render against. Shared by bin/render_pages.rb
# and check_styles.rb so there is one definition rather than two that drift.
#
# Every one is a plain Struct — that is the app contract being satisfied with
# no ceremony, which is the point.
module Fixtures
  module_function

  def labelled(struct, formats: {})
    struct.singleton_class.define_method(:format_for) { |a| formats[a] }
    struct
  end

  Holding = Struct.new(:symbol, :shares, :market_value, :gain, :weight, keyword_init: true)
  Account = Struct.new(:name, :id, :balance, :contribution_room, :tax_treatment, :holdings,
                       keyword_init: true)
  Target = Struct.new(:asset_class, :target, :actual, :drift, keyword_init: true)
  Contribution = Struct.new(:amount, :account_id, :frequency, :auto_invest, keyword_init: true)
  Portfolio = Struct.new(:as_of, :total_value, :ytd_return, :annual_income, :years_to_rmd,
                         :allocation, :balances, :years, :drifted?, :targets, :growth_rate,
                         :inflation_rate, :horizon_years, :contribution, :accounts,
                         keyword_init: true)

  Project = Struct.new(:path, :purpose, keyword_init: true)
  Pattern = Struct.new(:title, :category, :status, :origin_project, :origin_file, :content,
                       :lore, :projects, keyword_init: true)

  Finding = Struct.new(:severity, :summary, keyword_init: true)
  Surface = Struct.new(:name, :caption, :screenshot, :findings, keyword_init: true)
  Review = Struct.new(:reviewed_on, :reviewer, :introduction, :surfaces_reviewed,
                      :findings_open, :worst_severity, :surfaces, keyword_init: true)

  HOLDING_FORMATS = { shares: :number, market_value: :money, gain: :money,
                      weight: :percent }.freeze

  def holding(symbol, shares, value, gain, weight)
    labelled(Holding.new(symbol: symbol, shares: shares, market_value: value,
                         gain: gain, weight: weight), formats: HOLDING_FORMATS)
  end

  def account(name, id, balance, room, treatment, holdings)
    labelled(Account.new(name: name, id: id, balance: balance, contribution_room: room,
                         tax_treatment: treatment, holdings: holdings),
             formats: { balance: :money, contribution_room: :money })
  end

  def portfolio
    labelled(
      Portfolio.new(
        as_of: Date.new(2026, 8, 30), total_value: 1_284_506, ytd_return: 0.0742,
        annual_income: 48_200, years_to_rmd: 13,
        allocation: [0.63, 0.21, 0.16], balances: [900_000, 1_020_000, 1_284_506],
        years: [2024, 2025, 2026], drifted?: true,
        targets: targets, growth_rate: 0.05, inflation_rate: 0.02, horizon_years: 30,
        contribution: Contribution.new(amount: 500, account_id: 'roth',
                                       frequency: 'monthly', auto_invest: true),
        accounts: [
          account('Traditional IRA', 1, 417_530, 7_000, 'Pre-tax',
                  [holding('VTI', 1240, 356_120, 48_900, 0.42),
                   holding('VXUS', 890, 61_410, -3_180, 0.07)]),
          account('Roth IRA', 2, 117_760, 7_000, 'Tax-free',
                  [holding('VTI', 410, 117_760, 21_050, 0.14)])
        ]
      ),
      formats: { total_value: :money, ytd_return: :percent,
                 annual_income: :money, years_to_rmd: :number }
    )
  end

  def targets
    [['US equity', 0.60, 0.63, 0.03], ['International', 0.25, 0.21, -0.04],
     ['Bonds', 0.15, 0.16, 0.01]].map do |name, target, actual, drift|
      labelled(Target.new(asset_class: name, target: target, actual: actual, drift: drift),
               formats: { target: :percent, actual: :percent, drift: :percent })
    end
  end

  def pattern
    Pattern.new(
      title: 'Rapid Iterative Feedback', category: 'ux', status: 'canonical',
      origin_project: 'dashboard', origin_file: 'docs/pattern_rif.md',
      content: "A **four-step** loop.\n\n- Observe\n- Implement\n- Verify\n- Commit\n\n" \
               'See [the Ode](/ode).',
      lore: 'Feed this to any agent before development.',
      projects: [Project.new(path: 'abide', purpose: 'Habit tracker'),
                 Project.new(path: 'dashboard', purpose: 'Workspace memory')]
    )
  end

  def review
    Review.new(
      reviewed_on: Date.new(2026, 8, 27), reviewer: 'dan',
      introduction: "Every surface, *as reviewed*.\n\nScreenshots are regenerable.",
      surfaces_reviewed: 12, findings_open: 4, worst_severity: 'blocker',
      surfaces: [
        Surface.new(name: 'Triage', caption: 'The triage view, before the fix',
                    screenshot: '/.ocr/triage_big.png',
                    findings: [Finding.new(severity: 'blocker', summary: 'Links are not clickable.'),
                               Finding.new(severity: 'polish', summary: 'Badge spacing is tight.')]),
        Surface.new(name: 'Ports', caption: 'The ports table', screenshot: '/.ocr/ports_big.png',
                    findings: [Finding.new(severity: 'warning', summary: 'Sort order is not obvious.')])
      ]
    )
  end

  def scenario
    require '/home/dan/dev/roth/lib/engine/inputs'
    inputs = Engine::Inputs.from_hash(
      'age_primary' => 60, 'age_spouse' => 58, 'trad_balance' => 750_000,
      'roth_balance' => 150_000, 'base_income' => 80_000,
      'ss_primary_start_year' => 7, 'ss_primary_amount' => 45_000,
      'ss_spouse_start_year' => 9, 'ss_spouse_amount' => 22_000
    )
    inputs.singleton_class.define_method(:label_for) do |a|
      { age_primary: 'Age (primary)', age_spouse: 'Age (spouse)',
        trad_balance: 'Traditional balance', ss_primary_start_year: 'SS start (years from now)',
        ss_primary_amount: 'SS annual amount',
        ss_spouse_start_year: 'Spouse SS start (years from now)',
        ss_spouse_amount: 'Spouse SS annual amount', inflation_rate: 'Inflation',
        horizon_years: 'Horizon (years)', conversion_value: 'Strategy value',
        conversion_strategy: 'Strategy' }[a]
    end
    inputs
  end

  Specimen = Struct.new(:blurb, :markdown, :origin, :reviewed_on, :total_value, :ytd_return,
                        :holdings_count, :worst_day, :holdings, :drifted?, :nothing,
                        :balances, :years, :allocation, :example, :amount, :rate,
                        :frequency, :auto_invest, :growth_rate, :horizon_years,
                        keyword_init: true)

  def specimen
    labelled(
      Specimen.new(
        blurb: 'Every word in the vocabulary, on one page, so the design system can be looked at.',
        markdown: "Prose is **markdown**, rendered *safely* — there is no trust-me spelling.\n\n" \
                  "- escaped first\n- then a fixed set of patterns\n\nSee [the design](/design).",
        origin: 'dashboard', reviewed_on: Date.new(2026, 8, 30),
        total_value: 1_284_506, ytd_return: 0.0742, holdings_count: 3, worst_day: -3_180,
        holdings: [holding('VTI', 1240, 356_120, 48_900, 0.42),
                   holding('VXUS', 890, 61_410, -3_180, 0.07),
                   holding('BND', 410, 117_760, 21_050, 0.14)],
        drifted?: true, nothing: [],
        balances: [900_000, 980_000, 1_020_000, 1_180_000, 1_284_506],
        years: [2022, 2023, 2024, 2025, 2026],
        allocation: [0.63, 0.21, 0.16],
        example: "section holdings\n  each holding\n    money .market_value",
        amount: 500, rate: 0.05, frequency: 'monthly', auto_invest: true,
        growth_rate: 0.05, horizon_years: 30
      ),
      formats: { total_value: :money, ytd_return: :percent, holdings_count: :number,
                 worst_day: :money }
    )
  end

  # Which locals each page in pages/ needs. A page with no entry is not a page
  # — `layout.sp` is chrome, not something that renders alone.
  def for(name)
    case name
    when 'portfolio', 'portfolio_table' then { portfolio: portfolio }
    when 'account_detail' then { account: portfolio.accounts.last }
    when 'content' then { pattern: pattern }
    when 'figures' then { review: review }
    when 'roth_form' then { scenario: scenario }
    when 'specimen' then { specimen: specimen }
    end
  end
end
