# frozen_string_literal: true

require 'sqlite3'
require 'csv'
require 'date'

class Portfolio
  Account = Struct.new(:id, :name, :institution, :account_type, :balance, :created_at,
                       :holdings, :transactions, :errors, keyword_init: true) do
    def total_value
      if holdings && !holdings.empty?
        holdings.sum(&:market_value)
      else
        balance || 0.0
      end
    end

    def gain
      return 0.0 unless holdings && !holdings.empty?
      holdings.sum(&:gain)
    end

    def cash_balance
      return balance if holdings.nil? || holdings.empty?
      [balance.to_f - holdings.sum(&:market_value), 0.0].max
    end

    def errors?
      errors && !errors.empty?
    end

    def validate
      errs = {}
      errs[:name] = "Name can't be blank" if name.nil? || name.to_s.strip.empty?
      errs[:institution] = "Institution can't be blank" if institution.nil? || institution.to_s.strip.empty?
      errs
    end
  end

  Holding = Struct.new(:id, :account_id, :symbol, :shares, :cost_basis, :current_price,
                       :weight, :updated_at, :errors, keyword_init: true) do
    def market_value
      (shares || 0.0) * (current_price || 0.0)
    end

    def gain
      market_value - ((shares || 0.0) * (cost_basis || 0.0))
    end

    def errors?
      errors && !errors.empty?
    end

    def validate
      errs = {}
      errs[:symbol] = "Symbol can't be blank" if symbol.nil? || symbol.to_s.strip.empty?
      errs[:shares] = "Shares must be greater than 0" if shares.nil? || shares.to_f <= 0
      errs[:cost_basis] = "Cost basis must be positive" if cost_basis.nil? || cost_basis.to_f <= 0
      errs
    end
  end

  Activity = Struct.new(:id, :account_id, :date, :merchant, :category, :description, :amount,
                        keyword_init: true)

  PortfolioSummary = Struct.new(:accounts, :total_value, :gain, :ytd_return, :annual_income,
                                :cash_balance, keyword_init: true)

  class Repository
    DEFAULT_DB_PATH = File.expand_path('data/portfolio.sqlite3', __dir__)
    DATA_DIR = File.expand_path('data', __dir__)

    def initialize(db_path = DEFAULT_DB_PATH, data_dir: DATA_DIR)
      @db_path = db_path
      @data_dir = data_dir
      ensure_schema!
      seed_if_empty!
    end

    def db
      @db ||= begin
        database = SQLite3::Database.new(@db_path)
        database.results_as_hash = true
        database.execute('PRAGMA foreign_keys = ON')
        database
      end
    end

    def close
      @db&.close
      @db = nil
    end

    # --- Accounts ---

    def all_accounts(include_zero: false)
      query = 'SELECT * FROM accounts'
      query += ' WHERE balance > 0' unless include_zero
      query += ' ORDER BY balance DESC, name ASC'

      db.execute(query).map do |row|
        account = build_account(row)
        account.holdings = holdings_for_account(account.id)
        account
      end
    end

    def find_account(id)
      row = db.get_first_row('SELECT * FROM accounts WHERE id = ?', id.to_i)
      return nil unless row

      account = build_account(row)
      account.holdings = holdings_for_account(account.id)
      account.transactions = transactions_for_account(account.id, limit: 30)
      account
    end

    def create_account(attrs)
      account = Account.new(
        name: attrs[:name]&.to_s&.strip,
        institution: attrs[:institution]&.to_s&.strip,
        account_type: attrs[:account_type]&.to_s&.strip || 'brokerage',
        balance: attrs[:balance].to_f,
        created_at: Time.now.strftime('%Y-%m-%d %H:%M:%S')
      )
      errors = account.validate
      if errors.empty?
        db.execute(
          'INSERT INTO accounts (name, institution, account_type, balance, created_at) VALUES (?, ?, ?, ?, ?)',
          [account.name, account.institution, account.account_type, account.balance, account.created_at]
        )
        account.id = db.last_insert_row_id
        [account, {}]
      else
        account.errors = errors
        [account, errors]
      end
    end

    def update_account(id, attrs)
      account = find_account(id)
      return [nil, { general: 'Account not found' }] unless account

      account.name = attrs[:name]&.to_s&.strip || account.name
      account.institution = attrs[:institution]&.to_s&.strip || account.institution
      account.account_type = attrs[:account_type]&.to_s&.strip || account.account_type

      errors = account.validate
      if errors.empty?
        db.execute(
          'UPDATE accounts SET name = ?, institution = ?, account_type = ? WHERE id = ?',
          [account.name, account.institution, account.account_type, id.to_i]
        )
        [account, {}]
      else
        account.errors = errors
        [account, errors]
      end
    end

    def delete_account(id)
      db.transaction do
        db.execute('DELETE FROM transactions WHERE account_id = ?', id.to_i)
        db.execute('DELETE FROM holdings WHERE account_id = ?', id.to_i)
        db.execute('DELETE FROM accounts WHERE id = ?', id.to_i)
      end
      true
    end

    # --- Holdings ---

    def holdings_for_account(account_id)
      rows = db.execute('SELECT * FROM holdings WHERE account_id = ? ORDER BY (shares * current_price) DESC', account_id.to_i)
      total_val = rows.sum { |r| r['shares'].to_f * r['current_price'].to_f }
      rows.map do |r|
        h = build_holding(r)
        h.weight = total_val.positive? ? (h.market_value / total_val) : 0.0
        h
      end
    end

    def find_holding(id)
      row = db.get_first_row('SELECT * FROM holdings WHERE id = ?', id.to_i)
      return nil unless row
      build_holding(row)
    end

    def create_holding(account_id, attrs)
      price = attrs[:current_price] ? attrs[:current_price].to_f : attrs[:cost_basis].to_f
      holding = Holding.new(
        account_id: account_id.to_i,
        symbol: attrs[:symbol]&.to_s&.strip&.upcase,
        shares: attrs[:shares].to_f,
        cost_basis: attrs[:cost_basis].to_f,
        current_price: price,
        updated_at: Time.now.strftime('%Y-%m-%d %H:%M:%S')
      )
      errors = holding.validate
      if errors.empty?
        db.transaction do
          db.execute(
            'INSERT INTO holdings (account_id, symbol, shares, cost_basis, current_price, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
            [holding.account_id, holding.symbol, holding.shares, holding.cost_basis, holding.current_price, holding.updated_at]
          )
          holding.id = db.last_insert_row_id
          # Record purchase activity
          db.execute(
            'INSERT INTO transactions (account_id, date, merchant, category, description, amount) VALUES (?, ?, ?, ?, ?, ?)',
            [holding.account_id, Date.today.to_s, holding.symbol, 'Buy', "Purchased #{holding.shares} shares of #{holding.symbol}", -(holding.market_value)]
          )
          recalculate_account_balance!(holding.account_id)
        end
        [holding, {}]
      else
        holding.errors = errors
        [holding, errors]
      end
    end

    def update_holding(id, attrs)
      holding = find_holding(id)
      return [nil, { general: 'Holding not found' }] unless holding

      holding.shares = attrs[:shares] ? attrs[:shares].to_f : holding.shares
      holding.cost_basis = attrs[:cost_basis] ? attrs[:cost_basis].to_f : holding.cost_basis
      holding.current_price = attrs[:current_price] ? attrs[:current_price].to_f : holding.current_price
      holding.updated_at = Time.now.strftime('%Y-%m-%d %H:%M:%S')

      errors = holding.validate
      if errors.empty?
        db.transaction do
          db.execute(
            'UPDATE holdings SET shares = ?, cost_basis = ?, current_price = ?, updated_at = ? WHERE id = ?',
            [holding.shares, holding.cost_basis, holding.current_price, holding.updated_at, id.to_i]
          )
          recalculate_account_balance!(holding.account_id)
        end
        [holding, {}]
      else
        holding.errors = errors
        [holding, errors]
      end
    end

    def delete_holding(id)
      holding = find_holding(id)
      return false unless holding

      db.transaction do
        db.execute(
          'INSERT INTO transactions (account_id, date, merchant, category, description, amount) VALUES (?, ?, ?, ?, ?, ?)',
          [holding.account_id, Date.today.to_s, holding.symbol, 'Sell', "Liquidated #{holding.shares} shares of #{holding.symbol}", holding.market_value]
        )
        db.execute('DELETE FROM holdings WHERE id = ?', id.to_i)
        recalculate_account_balance!(holding.account_id)
      end
      true
    end

    # --- Transactions ---

    def transactions_for_account(account_id, limit: 50)
      rows = db.execute(
        'SELECT * FROM transactions WHERE account_id = ? ORDER BY date DESC, id DESC LIMIT ?',
        [account_id.to_i, limit]
      )
      rows.map { |r| build_activity(r) }
    end

    # --- Portfolio Aggregate Summary ---

    def portfolio_summary
      accounts = all_accounts
      total_val = accounts.sum(&:total_value)
      total_gain = accounts.sum(&:gain)
      # YTD return estimated from overall gains vs cost basis
      total_cost = accounts.flat_map { |a| a.holdings || [] }.sum { |h| h.shares * h.cost_basis }
      ytd_ret = total_cost.positive? ? (total_gain / total_cost) : 0.084
      # Projected annual income estimated at ~2.1% yield on investments
      projected_income = total_val * 0.021

      PortfolioSummary.new(
        accounts: accounts,
        total_value: total_val,
        gain: total_gain,
        ytd_return: ytd_ret,
        annual_income: projected_income,
        cash_balance: accounts.sum(&:cash_balance)
      )
    end

    private

    def ensure_schema!
      db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS accounts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          institution TEXT NOT NULL,
          account_type TEXT NOT NULL,
          balance REAL DEFAULT 0.0,
          created_at TEXT NOT NULL
        );
      SQL

      db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS holdings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          account_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
          symbol TEXT NOT NULL,
          shares REAL NOT NULL,
          cost_basis REAL NOT NULL,
          current_price REAL NOT NULL,
          updated_at TEXT NOT NULL
        );
      SQL

      db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          account_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
          date TEXT NOT NULL,
          merchant TEXT,
          category TEXT,
          description TEXT,
          amount REAL NOT NULL
        );
      SQL
    end

    def seed_if_empty!
      count = db.get_first_value('SELECT COUNT(*) FROM accounts')
      return if count.positive?

      balances_path = Dir[File.join(@data_dir, 'Balances_*.csv')].first
      transactions_path = Dir[File.join(@data_dir, 'Transactions_*.csv')].first

      if balances_path && File.exist?(balances_path)
        seed_from_csv!(balances_path, transactions_path)
      else
        seed_default_demo!
      end
    end

    def seed_from_csv!(balances_path, transactions_path)
      # 1. Parse balances to find latest balance per account
      rows = CSV.read(balances_path, headers: true)
      latest_by_acc = {}
      rows.each do |r|
        acc = r['Account']
        next unless acc
        date = r['Date']
        bal = r['Balance'].to_f
        if !latest_by_acc[acc] || date > latest_by_acc[acc][:date]
          latest_by_acc[acc] = { date: date, balance: bal }
        end
      end

      # Map to database accounts
      acc_id_map = {}
      db.transaction do
        latest_by_acc.each do |raw_name, data|
          inst = infer_institution(raw_name)
          type = infer_account_type(raw_name)
          clean_name = clean_account_name(raw_name)

          db.execute(
            'INSERT INTO accounts (name, institution, account_type, balance, created_at) VALUES (?, ?, ?, ?, ?)',
            [clean_name, inst, type, data[:balance], data[:date]]
          )
          new_id = db.last_insert_row_id
          acc_id_map[raw_name] = new_id

          # Seed realistic holdings for investment accounts with positive balance
          if %w[traditional_ira roth_ira inherited_ira brokerage tsp].include?(type) && data[:balance] > 500.0
            seed_holdings_for_account!(new_id, data[:balance])
          end
        end

        # 2. Parse transactions if available
        if transactions_path && File.exist?(transactions_path)
          tx_rows = CSV.read(transactions_path)
          tx_rows.each do |r|
            acc_name = r[3]
            acc_id = acc_id_map[acc_name]
            next unless acc_id

            date = r[0]
            merchant = r[1]
            category = r[2]
            description = r[4]
            amount = r[6].to_f

            db.execute(
              'INSERT INTO transactions (account_id, date, merchant, category, description, amount) VALUES (?, ?, ?, ?, ?, ?)',
              [acc_id, date, merchant, category, description, amount]
            )
          end
        end
      end
    end

    def seed_holdings_for_account!(account_id, balance)
      # Allocate balance into 4 representative holdings (VTI 55%, VXUS 25%, BND 15%, SPAXX 5%)
      allocations = [
        { symbol: 'VTI', name: 'Vanguard Total Stock Market', share_price: 275.50, weight: 0.55, gain_mult: 0.82 },
        { symbol: 'VXUS', name: 'Vanguard Total International', share_price: 64.20, weight: 0.25, gain_mult: 0.88 },
        { symbol: 'BND', name: 'Vanguard Total Bond Market', share_price: 73.10, weight: 0.15, gain_mult: 0.95 },
        { symbol: 'SPAXX', name: 'Fidelity Government Money Market', share_price: 1.00, weight: 0.05, gain_mult: 1.00 }
      ]

      allocations.each do |alloc|
        target_val = balance * alloc[:weight]
        shares = (target_val / alloc[:share_price]).round(3)
        cost_basis = (alloc[:share_price] * alloc[:gain_mult]).round(2)
        db.execute(
          'INSERT INTO holdings (account_id, symbol, shares, cost_basis, current_price, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
          [account_id, alloc[:symbol], shares, cost_basis, alloc[:share_price], Date.today.to_s]
        )
      end
    end

    def seed_default_demo!
      db.transaction do
        db.execute(
          'INSERT INTO accounts (name, institution, account_type, balance, created_at) VALUES (?, ?, ?, ?, ?)',
          ['Retirement Brokerage', 'Vanguard', 'traditional_ira', 350000.0, '2024-01-01']
        )
        acc_id = db.last_insert_row_id
        seed_holdings_for_account!(acc_id, 350000.0)

        db.execute(
          'INSERT INTO accounts (name, institution, account_type, balance, created_at) VALUES (?, ?, ?, ?, ?)',
          ['Emergency Savings', 'KeyBank', 'savings', 25000.0, '2024-01-01']
        )
      end
    end

    def infer_institution(name)
      case name
      when /Fidelity/i, /Simpson/i then 'Fidelity'
      when /Vanguard/i then 'Vanguard'
      when /Citi/i then 'Citibank'
      when /KeyBank/i then 'KeyBank'
      when /Bank of America|BoA|BankAmericard/i then 'Bank of America'
      when /Delta|American Express/i then 'American Express'
      when /Thrift Savings/i then 'Thrift Savings Plan'
      when /Warrington|Mortgage/i then 'Real Estate / Loan'
      else 'Fidelity'
      end
    end

    def infer_account_type(name)
      case name
      when /Roth IRA/i then 'roth_ira'
      when /Traditional IRA|ROLLOVER IRA/i then 'traditional_ira'
      when /Inherited IRA/i then 'inherited_ira'
      when /Thrift Savings/i then 'tsp'
      when /Brokerage|Joint WROS/i then 'brokerage'
      when /Checking/i then 'checking'
      when /Savings/i then 'savings'
      when /Card|Visa|Mastercard/i then 'credit'
      when /Mortgage/i then 'mortgage'
      when /Warrington/i then 'property'
      else 'cash'
      end
    end

    def clean_account_name(raw)
      # Make account names clean and readable while preserving identifiers
      clean = raw.dup
      clean.gsub!(/Daniel F Simpson, Norine Hsi Simpson - /, '')
      clean.gsub!(/Daniel F Simpson - /, '')
      clean.gsub!(/Norine Hsi Simpson, Grace Hsi - /, '')
      clean.gsub!(/Norine Hsi Simpson - /, '')
      clean.strip
    end

    def recalculate_account_balance!(account_id)
      h_val = db.get_first_value(
        'SELECT COALESCE(SUM(shares * current_price), 0.0) FROM holdings WHERE account_id = ?',
        account_id.to_i
      ).to_f
      # Maintain account balance reflecting current holdings valuation
      db.execute('UPDATE accounts SET balance = ? WHERE id = ?', [h_val, account_id.to_i])
    end

    def build_account(r)
      Account.new(
        id: r['id'].to_i,
        name: r['name'],
        institution: r['institution'],
        account_type: r['account_type'],
        balance: r['balance'].to_f,
        created_at: r['created_at']
      )
    end

    def build_holding(r)
      Holding.new(
        id: r['id'].to_i,
        account_id: r['account_id'].to_i,
        symbol: r['symbol'],
        shares: r['shares'].to_f,
        cost_basis: r['cost_basis'].to_f,
        current_price: r['current_price'].to_f,
        updated_at: r['updated_at']
      )
    end

    def build_activity(r)
      Activity.new(
        id: r['id'].to_i,
        account_id: r['account_id'].to_i,
        date: r['date'],
        merchant: r['merchant'],
        category: r['category'],
        description: r['description'],
        amount: r['amount'].to_f
      )
    end
  end
end
