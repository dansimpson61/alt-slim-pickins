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

  set :views, File.join(__dir__, 'views')
  # The tin asks for /assets/slim-pickins.css, so the repo root is the
  # public folder — not the assets directory, which would serve it at /.
  set :public_folder, File.expand_path('../..', __dir__)
  set :static, true
  # A `Sinatra::Base` subclass does not parse ARGV, so `-p` is silently
  # ignored and `run!` takes 4567 — which roth is usually holding.
  set :port, ENV.fetch('PORT', 4576).to_i
  enable :method_override

  # One place says what this app's vocabulary is — its own words ride the
  # same Library as the built-ins.
  SlimPickins::Template.libraries[settings.views] =
    SlimPickins::Library.from(settings.views, words: AppWords)

  # Boot proves the pages: a view the app cannot answer fails here, naming
  # the line — before any request can render it blank.
  SlimPickins.prove!(settings.views, words: AppWords) do |name|
    repo = Portfolio::Repository.new
    account = repo.all_accounts.first || Fixtures.portfolio.accounts.last
    case name
    when 'index' then { portfolio: repo.portfolio_summary }
    when 'account', 'confirm_close' then { account: account }
    end
  end

  helpers do
    def repo
      @repo ||= Portfolio::Repository.new
    end

    def portfolio
      if settings.environment == :test && !ENV['PORTFOLIO_SQLITE']
        Fixtures.portfolio
      else
        repo.portfolio_summary
      end
    end
  end

  get '/' do
    sp :index, locals: { portfolio: portfolio }
  end

  get '/accounts/:id' do
    account = if settings.environment == :test && !ENV['PORTFOLIO_SQLITE']
                portfolio.accounts.find { |a| a.id.to_s == params[:id] }
              else
                repo.find_account(params[:id])
              end
    halt 404 unless account
    sp :account, locals: { account: account }
  end

  get '/accounts/:id/close' do
    account = repo.find_account(params[:id]) or halt 404
    sp :confirm_close, locals: { account: account }
  end

  delete '/accounts/:id' do
    repo.delete_account(params[:id])
    redirect '/'
  end

  get '/assets/slim-pickins.css' do
    content_type 'text/css'
    send_file File.expand_path('../../lib/slim_pickins/assets/slim-pickins.css', __dir__)
  end

  run! if app_file == $PROGRAM_NAME
end
