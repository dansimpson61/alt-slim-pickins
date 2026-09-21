# frozen_string_literal: true

# Phase 4, the exam: the dashboard's /triage, authored in slim-pickins.
# This app reads the dashboard's pure-Ruby lib (scan, workspace) and its
# stylesheet, shapes the queue's judgements into locals, and renders the
# views — the vocabulary's words and the partials in views/partials — with
# the four triage actions wired to the same Workspace calls the original
# makes. ~/dev/dashboard itself is never written to.

require 'sinatra/base'
require 'uri'
require 'ostruct'
require_relative '../../lib/slim_pickins/template'

require '/home/dan/dev/dashboard/lib/workspace'
require '/home/dan/dev/dashboard/lib/scan'
require '/home/dan/dev/dashboard/lib/library'
require '/home/dan/dev/dashboard/lib/architecture'
require '/home/dan/dev/dashboard/lib/health'

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
      when 'brief'
        base.merge(page_title: 'example — Brief', project_href: '/projects/example',
                   raw_href: '/brief/example?format=text', brief_markdown: '# Example')
      when 'doc'
        base.merge(page_title: 'example — Doc', project_href: '/projects/example',
                   doc_path: 'docs/SPEC.md', content: '# Specification')
      when 'pattern'
        base.merge(title: 'Example Pattern', category_name: 'architecture',
                   emerging: false, origin_line: 'Origin: example / SPEC.md',
                   content: '# Pattern', has_projects: false, projects: [], lore: 'Lore')
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

      def brief_text(p)
        out = []
        out << "# #{p[:path]}"
        stale_text = p[:stale_days] ? "#{p[:stale_days]}d" : 'n/a'
        out << "**Status:** `#{p[:status]}` · **Last Touched:** `#{p[:last_touched] || '-'}` · **Stale:** `#{stale_text}`"
        out << ''
        out << "> **Purpose:** #{p[:purpose]}"
        out << "> **Next Horizon:** #{p[:next_step]}"
        out << ''
        out << "- **Run Command:** `#{p[:run] || '-'}`"
        out << "- **Documentation:** `#{p[:docs] || '-'}`"
        out << "- **Related Projects:** #{Array(p[:related]).empty? ? 'none' : Array(p[:related]).join(', ')}"
        out << "- **Domain Patterns:** #{Array(p[:patterns]).join(', ')}" if p[:patterns] && !p[:patterns].empty?
        out << ''
        if (p[:notes] && !p[:notes].to_s.strip.empty?) || (p[:conventions] && !p[:conventions].to_s.strip.empty?) || (p[:gotchas] && !p[:gotchas].to_s.strip.empty?)
          out << '### Lore & Conventions'
          out << "- **Conventions:** #{p[:conventions]}" if p[:conventions] && !p[:conventions].to_s.strip.empty?
          out << "- **Gotchas:** #{p[:gotchas]}" if p[:gotchas] && !p[:gotchas].to_s.strip.empty?
          out << "- **Notes:** #{p[:notes]}" if p[:notes] && !p[:notes].to_s.strip.empty?
          out << ''
        end
        lore = Scan.lore_entries(p[:path]) rescue []
        unless lore.empty?
          out << '### Lore (latest)'
          lore.each { |e| out << "- **#{e[:date]} — #{e[:who]}:** #{e[:text].gsub("\n", ' ')[0, 240]}" }
          out << ''
        end
        anatomy = Architecture.anatomy(p[:path]) rescue {}
        unless Architecture.anatomy_empty?(anatomy)
          out << '### Anatomy'
          { 'Routes' => anatomy[:routes], 'Classes' => Architecture.class_labels(anatomy),
            'Views' => anatomy[:views], 'Configs' => anatomy[:configs] }.each do |label, list|
            next if list.nil? || list.empty?

            shown = list.first(15).join(', ')
            more = list.size > 15 ? " (+#{list.size - 15} more)" : ''
            out << "- **#{label} (#{list.size}):** #{shown}#{more}"
          end
          out << "- **Vocabulary:** #{anatomy[:tokens].first(12).join(', ')}" if anatomy[:tokens] && !anatomy[:tokens].empty?
          out << "- **Layers:** #{Architecture.layer_line(anatomy)}"
          out << ''
        end
        if (h = Health.for(p[:path]) rescue nil)
          boot_note = h['boot'] == 'fail' ? " (#{h['boot_note']})" : ''
          tests_note = h['tests'] == 'fail' ? " (#{h['tests_note']})" : ''
          out << "- **Health:** boot #{h['boot']}#{boot_note} · tests #{h['tests']}#{tests_note} · checked #{h['checked_at']}"
        end
        out << "- **Flags:** #{p[:flags].join(' ')}" if p[:flags] && !p[:flags].empty?
        out << "- **Last Commit:** #{p[:last_commit] || '-'}"
        if p[:recent_commits] && !p[:recent_commits].empty?
          out << ''
          out << '### Recent Commits'
          p[:recent_commits].each { |c| out << "- #{c}" }
        end
        out.join("\n") + "\n"
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

    get '/brief/:project' do
      project = params['project']
      halt 404, "Project #{project} not found" unless File.directory?(File.join(Scan::ROOT, project))
      p = Scan.brief(project)
      halt 404, "Project #{project} not found" unless p

      brief_md = brief_text(p)
      if params['format'] == 'text'
        content_type 'text/plain'
        return brief_md
      end

      @view = 'brief'
      sp :brief, locals: {
        page_title: "#{project} — Brief",
        project_href: "/projects/#{project}",
        raw_href: "/brief/#{project}?format=text",
        brief_markdown: brief_md,
        notice: params['notice'], q: params['q'].to_s,
        error_entry: error_entry, nav_state: nav_map
      }
    end

    get '/projects/*/docs/*' do
      splats = params['splat'].to_a
      project = splats.first.to_s
      doc_path = splats.last.to_s
      halt 404, 'not found' if project.include?('..') || doc_path.include?('..')

      full_path = File.join(Scan::ROOT, project, doc_path)
      halt 404, 'doc not found' unless File.file?(full_path)

      title = File.foreach(full_path).first(10).find { |l| l.start_with?('# ') }&.sub(/\A#\s*/, '')&.strip || File.basename(doc_path)
      content = File.read(full_path)

      @view = 'studio'
      sp :doc, locals: {
        page_title: title,
        project_href: "/projects/#{project}",
        doc_path: "#{project}/#{doc_path}",
        content: content,
        notice: params['notice'], q: params['q'].to_s,
        error_entry: error_entry, nav_state: nav_map
      }
    end

    get '/patterns/:id' do
      pattern = Library.find_pattern(params['id'])
      halt 404, 'Pattern not found' unless pattern

      content = Library.pattern_content(pattern)
      projects = Library.projects_for_pattern(pattern)
      lore = Library.prompt_lore_for_pattern(pattern)

      @view = 'library'
      sp :pattern, locals: {
        title: pattern[:title],
        category_name: pattern[:category].to_s,
        emerging: pattern[:emerging] || false,
        origin_line: "Origin: #{pattern[:origin_project]} / #{pattern[:origin_file]}",
        content: content,
        has_projects: !projects.empty?,
        projects: projects.map { |pr| OpenStruct.new(path: pr[:path], purpose: pr[:purpose]) },
        lore: lore,
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
      File.read(File.expand_path('../../assets/slim-pickins.css', __dir__))
    end

    get '/assets/slim-pickins.css' do
      content_type 'text/css'
      File.read(File.expand_path('../../assets/slim-pickins.css', __dir__))
    end

    run! if app_file == $PROGRAM_NAME
  end
end
