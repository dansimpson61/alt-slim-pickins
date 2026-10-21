# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../examples/portfolio/repository'
require 'tmpdir'
require 'fileutils'

class PortfolioRepositoryTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir
    @db_path = File.join(@dir, 'test_portfolio.sqlite3')
    @repo = Portfolio::Repository.new(@db_path, data_dir: @dir)
  end

  def teardown
    @repo.close
    FileUtils.remove_entry(@dir) if File.exist?(@dir)
  end

  def test_seeds_default_demo_when_no_csvs_present
    accounts = @repo.all_accounts
    refute_empty accounts
    assert_equal 2, accounts.size

    ira = accounts.find { |a| a.account_type == 'traditional_ira' }
    assert ira
    assert_equal 4, ira.holdings.size
    assert_in_delta 350000.0, ira.total_value, 1.0
  end

  def test_seeds_from_local_csvs_when_present
    csv_path = Dir[File.join(Portfolio::Repository::DATA_DIR, 'Balances_*.csv')].first
    skip 'No local CSV files present' unless csv_path && File.exist?(csv_path)

    csv_db_path = File.join(@dir, 'csv_portfolio.sqlite3')
    csv_repo = Portfolio::Repository.new(csv_db_path)
    begin
      accounts = csv_repo.all_accounts
      assert accounts.size >= 10
      summary = csv_repo.portfolio_summary
      assert summary.total_value > 1_000_000.0
    ensure
      csv_repo.close
    end
  end

  def test_create_account_and_validation
    # Invalid: missing name and institution
    account, errors = @repo.create_account(name: '', institution: '')
    assert account.errors?
    assert errors[:name]
    assert errors[:institution]

    # Valid account
    account, errors = @repo.create_account(
      name: 'High Yield Savings',
      institution: 'Marcus',
      account_type: 'savings',
      balance: 15000.0
    )
    assert errors.empty?
    refute account.errors?
    assert account.id

    found = @repo.find_account(account.id)
    assert_equal 'High Yield Savings', found.name
    assert_equal 15000.0, found.total_value
  end

  def test_update_and_delete_account
    account, = @repo.create_account(name: 'Temporary Account', institution: 'TestBank', balance: 100.0)
    assert account.id

    updated, errors = @repo.update_account(account.id, name: 'Renamed Account')
    assert errors.empty?
    assert_equal 'Renamed Account', updated.name

    assert @repo.delete_account(account.id)
    assert_nil @repo.find_account(account.id)
  end

  def test_create_update_and_delete_holding
    account, = @repo.create_account(name: 'Brokerage', institution: 'Schwab', account_type: 'brokerage')

    # Invalid holding: zero shares
    holding, errors = @repo.create_holding(account.id, symbol: 'AAPL', shares: 0, cost_basis: 150.0)
    assert errors[:shares]

    # Valid holding
    holding, errors = @repo.create_holding(
      account.id,
      symbol: 'AAPL',
      shares: 10,
      cost_basis: 150.0,
      current_price: 220.0
    )
    assert errors.empty?
    assert_equal 2200.0, holding.market_value
    assert_equal 700.0, holding.gain

    # Account total value updates
    account = @repo.find_account(account.id)
    assert_equal 2200.0, account.total_value

    # Update holding
    updated, = @repo.update_holding(holding.id, shares: 15, current_price: 200.0)
    assert_equal 3000.0, updated.market_value

    account = @repo.find_account(account.id)
    assert_equal 3000.0, account.total_value

    # Delete holding
    assert @repo.delete_holding(holding.id)
    account = @repo.find_account(account.id)
    assert_equal 0.0, account.total_value
  end

  def test_portfolio_summary_calculations
    summary = @repo.portfolio_summary
    assert summary.total_value.positive?
    assert summary.annual_income.positive?
    assert summary.ytd_return.positive?
  end
end
