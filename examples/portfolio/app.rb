# frozen_string_literal: true

# A real Sinatra app whose views are written in this language. `.sp` files
# render the way `.slim` ones do, through Tilt.

require 'sinatra/base'
require_relative '../../lib/slim_pickins/template'
require_relative '../../test/fixtures'

# The escape hatch. The vocabulary has no word for an embedded video, and the
# right answer is not to add one to slim-pickins — it is for this app to add a
# word of its own, in Ruby. A page then says `video .clip_url` and no reader
# can tell it apart from a built-in.
module AppWords
  def video(*args, poster: nil)
    _, source = arguments(args)
    html(%(<video class="#{token(:video)}" src="#{escape(source)}") +
         (poster ? %( poster="#{escape(poster)}") : '') +
         ' controls playsinline></video>')
  end
end

class Portfolio < Sinatra::Base
  helpers SlimPickins::Helpers

  set :views, File.join(__dir__, 'views')
  # The layout asks for /assets/slim-pickins.css, so the repo root is the
  # public folder — not the assets directory, which would serve it at /.
  set :public_folder, File.expand_path('../..', __dir__)
  set :static, true

  # One place says what this app's vocabulary is.
  SlimPickins::Template.libraries[settings.views] =
    SlimPickins::Library.from(settings.views).tap do |lib|
      lib.instance_variable_set(:@words, AppWords)
    end

  helpers do
    def portfolio = Fixtures.portfolio
  end

  get '/' do
    sp :index, locals: { portfolio: portfolio }
  end

  get '/accounts/:id' do
    account = portfolio.accounts.find { |a| a.id.to_s == params[:id] } or halt 404
    sp :account, locals: { account: account }
  end

  run! if app_file == $PROGRAM_NAME
end
