# frozen_string_literal: true

# Phase 4, the exam: the dashboard's /triage, authored in slim-pickins.
# This app reads the dashboard's pure-Ruby lib (scan, workspace) and its
# stylesheet, shapes the queue's judgements into locals, and renders the
# views — the vocabulary's words and the partials in views/partials — with
# the four triage actions wired to the same Workspace calls the original
# makes. ~/dev/dashboard itself is never written to.

require 'sinatra/base'
require 'uri'
require_relative '../../lib/slim_pickins/template'

require '/home/dan/dev/dashboard/lib/workspace'
require '/home/dan/dev/dashboard/lib/scan'

module DashboardPort
  class App < Sinatra::Base
    helpers SlimPickins::Helpers

    set :views, File.join(__dir__, 'views')
    set :port, ENV.fetch('PORT', 4578).to_i

    SlimPickins::Template.libraries[settings.views] = SlimPickins::Library.from(settings.views)

    # Boot proves the pages: a field the queue asks for that Scan no longer
    # answers fails here, naming the line — the payload, working for the
    # exam's app too.
    SlimPickins.prove!(settings.views) do |name|
      base = { notice: nil, q: '', error_entry: nil,
               nav_state: { studio: false, library: false, reconcile: false,
                      dispatch: false, ports: false } }
      case name
      when 'triage'
        base.merge(first_item: nil, queue_intro: '', unreviewed: nil)
      when 'confirm_archive'
        base.merge(archive_heading: 'Archive "example"?', archive_path: 'example',
                   archive_return_to: '/triage', reason: '')
      end
    end

    helpers do
      # The original layout's active-link rule: @nav wins, then the view and
      # path rules. For /triage none of them fire — the port matches.
      def nav_here?(section)
        return true if @nav == section

        path = request.path_info
        case section
        when 'studio' then %w[studio table tree].include?(@view) || (@view.nil? && path == '/')
        when 'library' then @view == 'library' || path.start_with?('/library')
        when 'reconcile' then %w[reconcile clusters compare related archived].include?(@view) || path.start_with?('/reconcile')
        when 'dispatch' then %w[dispatch instructions].include?(@view) || path.start_with?('/dispatch')
        when 'ports' then @view == 'ports'
        else false
        end
      end

      def nav_map
        { studio: nav_here?('studio'), library: nav_here?('library'),
          reconcile: nav_here?('reconcile'), dispatch: nav_here?('dispatch'),
          ports: nav_here?('ports') }
      end

      def status_variant(status)
        { 'active' => :ok, 'repaired' => :ok, 'abandoned' => :danger,
          'dormant' => :pending }.fetch(status, :neutral)
      end

      # Judgement belongs to the app; the page says only mechanical facts.
      # Each queue item is decorated with the sentences and choices the view
      # used to compute in Ruby, so the partial has nothing to decide.
      def decorate(p)
        { path: p[:path], status: p[:status],
          status_variant: status_variant(p[:status]),
          stale_text: p[:stale_days] ? "stale #{p[:stale_days]}d" : 'never committed',
          purpose: p[:purpose],
          next_line: (p[:next_step] == '-' ? nil : "Next: #{p[:next_step]}"),
          offer_commit: p[:dirty] || p[:zero_commits] }
      end

      def unreviewed_sentence
        n = Scan.instruction_files.count { |f| f[:disposition] == 'unreviewed' }
        return if n.zero?

        "#{n} instruction file#{'s' if n > 1} awaiting judgment — hand-kept rules nobody has ruled canonical or legacy."
      end

      def error_entry
        err = Workspace.recent_error
        return unless err && !err[:log].to_s.strip.empty?

        { project: "Launch Error Log — #{err[:project]}", log: err[:log],
          href: "/projects/#{err[:project]}" }
      end

      def redirect_with_notice(message)
        target = params['return_to'].to_s.strip
        target = '/' if target.empty?
        target += target.include?('?') ? '&' : '?'
        redirect "#{target}notice=#{URI.encode_www_form_component(message)}"
      end
    end

    get '/' do
      redirect '/triage'
    end

    get '/triage' do
      @view = 'triage'
      queue = Scan.triage_queue
      sp :triage, locals: {
        first_item: (decorate(queue.first) if queue.first),
        queue_intro: "#{queue.size} item(s) need attention — this is the first:",
        unreviewed: unreviewed_sentence,
        notice: params['notice'], q: params['q'].to_s,
        error_entry: error_entry, nav_state: nav_map
      }
    end

    post '/actions/commit' do
      _ok, message = Workspace.commit!(params['path'])
      redirect_with_notice(message)
    end

    post '/actions/status' do
      _ok, message = Workspace.set_status!(params['path'], params['status'])
      redirect_with_notice(message)
    end

    post '/actions/skip' do
      _ok, message = Workspace.skip!(params['path'])
      redirect_with_notice(message)
    end

    post '/actions/archive' do
      rel = params['path'].to_s
      if params['confirmed'] != '1'
        sp :confirm_archive, locals: {
          archive_heading: %(Archive "#{rel}"?),
          archive_path: rel, archive_return_to: params['return_to'],
          reason: params['reason'].to_s,
          notice: nil, q: '', error_entry: nil, nav_state: nav_map
        }
      else
        _ok, message = Workspace.archive!(rel, reason: params['reason'], reference: params['reference'])
        redirect_with_notice(message)
      end
    end

    get '/assets/stylesheets/slim-pickins.css' do
      content_type 'text/css'
      File.read('/home/dan/dev/slim-pickins/slim-pickins/assets/stylesheets/slim-pickins.css')
    end

    run! if app_file == $PROGRAM_NAME
  end
end
