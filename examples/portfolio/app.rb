# frozen_string_literal: true

# A real Sinatra app whose views are written in this language. `.sp` files
# render the way `.slim` ones do, through Tilt.

require 'sinatra/base'
require_relative '../../lib/slim_pickins/template'
require_relative 'repository'
require_relative '../../test/fixtures'

# The escape hatch. The vocabulary has no word for an embedded video, and the
# right answer is not to add one to slim-pickins — it is for this app to add a
# word of its own, in Ruby. A page then says `video .clip_url` and no reader
# can tell it apart from a built-in.
module AppWords
  def video(*args, poster: nil)
    _, source = arguments(args)
    tag(:video, { class: token(:video), src: source, poster: poster,
                  controls: true, playsinline: true })
  end
end

class Portfolio < Sinatra::Base
  helpers SlimPickins::Helpers

  set :app_file, __FILE__
  set :views, File.join(__dir__, 'views')
  # The tin asks for /assets/slim-pickins.css, so the repo root is the
  # public folder — not the assets directory, which would serve it at /.
  set :public_folder, File.expand_path('../..', __dir__)
  set :static, true
  # A `Sinatra::Base` subclass does not parse ARGV, so `-p` is silently
  # ignored and `run!` takes 4567 — which roth is usually holding.
  set :port, ENV.fetch('PORT', 4576).to_i
  enable :method_override
  enable :sessions
  set :session_secret, ENV.fetch('SESSION_SECRET', 'portfolio_workbench_session_secret_fixed_for_demo_and_test_32chars')

  # One place says what this app's vocabulary is — its own words ride the
  # same Library as the built-ins.
  SlimPickins::Template.libraries[settings.views] =
    SlimPickins::Library.from(settings.views, words: AppWords)

  # Boot proves the pages: a view the app cannot answer fails here, naming
  # the line — before any request can render it blank.
  SlimPickins.prove!(settings.views, words: AppWords) do |name|
    repo = Portfolio::Repository.new
    account = repo.all_accounts.first || Fixtures.portfolio.accounts.last
    holding = account.holdings&.first || Fixtures.portfolio_holding
    case name
    when 'index' then { portfolio: repo.portfolio_summary }
    when 'account', 'confirm_close', 'new_account', 'edit_account' then { account: account }
    when 'new_holding', 'edit_holding', 'confirm_sell' then { holding: holding, account: account }
    end
  end

  helpers do
    def repo
      @repo ||= Portfolio::Repository.new
    end

    def flash_notice
      session[:notice] ? session.delete(:notice) : nil
    end

    def find_account_or_fixture(id)
      if settings.environment == :test && !ENV['PORTFOLIO_SQLITE']
        Fixtures.portfolio.accounts.find { |a| a.id.to_s == id.to_s } || repo.find_account(id)
      else
        repo.find_account(id)
      end
    end

    def find_holding_or_fixture(id)
      if settings.environment == :test && !ENV['PORTFOLIO_SQLITE']
        Fixtures.portfolio.accounts.flat_map(&:holdings).find { |h| h.id.to_s == id.to_s } || repo.find_holding(id)
      else
        repo.find_holding(id)
      end
    end

    def portfolio
      p = if settings.environment == :test && !ENV['PORTFOLIO_SQLITE']
            Fixtures.portfolio
          else
            repo.portfolio_summary
          end
      p.notice = flash_notice
      p
    end
  end

  get '/' do
    sp :index, locals: { portfolio: portfolio }
  end

  get '/accounts/new' do
    account = Portfolio::Account.new(account_type: 'brokerage', notice: flash_notice)
    sp :new_account, locals: { account: account }
  end

  post '/accounts' do
    attrs = {
      name: params[:name] || params['name'],
      institution: params[:institution] || params['institution'],
      account_type: params[:account_type] || params['account_type'],
      balance: params[:balance] || params['balance']
    }
    account, errors = repo.create_account(attrs)
    if errors.empty?
      session[:notice] = "Account \"#{account.name}\" was successfully opened."
      redirect "/accounts/#{account.id}"
    else
      status 422
      sp :new_account, locals: { account: account }
    end
  end

  get '/accounts/:id' do
    account = if settings.environment == :test && !ENV['PORTFOLIO_SQLITE']
                Fixtures.portfolio.accounts.find { |a| a.id.to_s == params[:id] } || repo.find_account(params[:id])
              else
                repo.find_account(params[:id])
              end
    halt 404 unless account
    account.notice = flash_notice
    sp :account, locals: { account: account }
  end

  get '/accounts/:id/edit' do
    account = if settings.environment == :test && !ENV['PORTFOLIO_SQLITE']
                Fixtures.portfolio.accounts.find { |a| a.id.to_s == params[:id] } || repo.find_account(params[:id])
              else
                repo.find_account(params[:id])
              end
    halt 404 unless account
    account.notice = flash_notice
    sp :edit_account, locals: { account: account }
  end

  patch '/accounts/:id' do
    attrs = {
      name: params[:name] || params['name'],
      institution: params[:institution] || params['institution'],
      account_type: params[:account_type] || params['account_type']
    }
    account, errors = repo.update_account(params[:id], attrs)
    halt 404 unless account
    if errors.empty?
      session[:notice] = "Account \"#{account.name}\" was successfully updated."
      redirect "/accounts/#{account.id}"
    else
      status 422
      sp :edit_account, locals: { account: account }
    end
  end

  get '/accounts/:id/close' do
    account = find_account_or_fixture(params[:id])
    halt 404 unless account
    account.notice = flash_notice
    sp :confirm_close, locals: { account: account }
  end

  delete '/accounts/:id' do
    account = repo.find_account(params[:id])
    name = account ? account.name : 'Account'
    repo.delete_account(params[:id])
    session[:notice] = "#{name} was successfully closed."
    redirect '/'
  end

  # --- Holdings CRUD ---

  get '/accounts/:id/holdings/new' do
    account = find_account_or_fixture(params[:id])
    halt 404 unless account
    holding = Portfolio::Holding.new(account_id: account.id, notice: flash_notice)
    sp :new_holding, locals: { holding: holding, account: account }
  end

  post '/accounts/:id/holdings' do
    account = find_account_or_fixture(params[:id])
    halt 404 unless account
    attrs = {
      symbol: params[:symbol] || params['symbol'],
      shares: params[:shares] || params['shares'],
      cost_basis: params[:cost_basis] || params['cost_basis'],
      current_price: params[:current_price] || params['current_price']
    }
    holding, errors = repo.create_holding(account.id, attrs)
    if errors.empty?
      session[:notice] = "Added #{holding.shares} shares of #{holding.symbol}."
      redirect "/accounts/#{account.id}"
    else
      status 422
      holding.notice = flash_notice
      sp :new_holding, locals: { holding: holding, account: account }
    end
  end

  get '/holdings/:id/edit' do
    holding = find_holding_or_fixture(params[:id])
    halt 404 unless holding
    account = find_account_or_fixture(holding.account_id)
    holding.notice = flash_notice
    sp :edit_holding, locals: { holding: holding, account: account }
  end

  put '/holdings/:id' do
    attrs = {
      symbol: params[:symbol] || params['symbol'],
      shares: params[:shares] || params['shares'],
      cost_basis: params[:cost_basis] || params['cost_basis'],
      current_price: params[:current_price] || params['current_price']
    }
    holding, errors = repo.update_holding(params[:id], attrs)
    halt 404 unless holding
    if errors.empty?
      session[:notice] = "Updated position for #{holding.symbol}."
      redirect "/accounts/#{holding.account_id}"
    else
      status 422
      account = find_account_or_fixture(holding.account_id)
      holding.notice = flash_notice
      sp :edit_holding, locals: { holding: holding, account: account }
    end
  end

  get '/holdings/:id/sell' do
    holding = find_holding_or_fixture(params[:id])
    halt 404 unless holding
    account = find_account_or_fixture(holding.account_id)
    holding.notice = flash_notice
    sp :confirm_sell, locals: { holding: holding, account: account }
  end

  delete '/holdings/:id' do
    holding = repo.find_holding(params[:id])
    halt 404 unless holding
    acc_id = holding.account_id
    symbol = holding.symbol
    shares = holding.shares
    val = holding.market_value
    repo.delete_holding(params[:id])
    session[:notice] = "Liquidated #{shares} shares of #{symbol} for #{SlimPickins::Generator.format(:money, val)}."
    redirect "/accounts/#{acc_id}"
  end

  get '/assets/:file' do
    content_type 'text/css'
    case params[:file]
    when 'slim-pickins.css'
      send_file File.expand_path('../../lib/slim_pickins/assets/slim-pickins.css', __dir__)
    when 'portfolio.css'
      layout_file = File.expand_path('portfolio.layout', __dir__)
      halt 404 unless File.file?(layout_file)
      SlimPickins::Layout.compiled_stylesheet(
        File.read(layout_file),
        provenance: 'automatically from examples/portfolio/portfolio.layout'
      )
    when 'portfolio.style.css'
      style_file = File.expand_path('portfolio.style', __dir__)
      halt 404 unless File.file?(style_file)
      SlimPickins::Style.compiled_stylesheet(
        File.read(style_file),
        provenance: 'automatically from examples/portfolio/portfolio.style'
      )
    else
      halt 404
    end
  end

  run! if $PROGRAM_NAME == __FILE__
end
