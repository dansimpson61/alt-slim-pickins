# frozen_string_literal: true

# The studio's UIs: several workbenches, one registry, one picker.
#
# A UI is a directory under `studio/uis/` holding four things and nothing
# else:
#
#   layout.sp     the frame — assets and chrome, declared once, inferred by
#                 `page` (`Library.from` reads it; no page mentions it)
#   views/        the pages, plus `views/partials/` if the UI has fragments
#   words.rb      the UI's own vocabulary, a module extending StudioUI
#   about.rb      the module API: TITLE, DESIGN, and `paths` — how this UI
#                 mints its own URLs
#
# `paths` is the seam that makes several UIs possible. Every link a UI offers
# is minted in Ruby (the palette's load paths, the docs' word paths), so a
# literal `/` would send a visitor from one UI into another. A UI's `paths`
# answers for its own URLs, and the routes and payloads ask rather than
# hardcode.
#
# The picker: `?ui=<name>` selects, a cookie remembers, and the default is
# dan's choice for a visitor who has not picked. A UI links to its own pages
# without carrying the parameter — navigation stays clean and the choice
# survives it — and switching is one explicit `/ui/<name>`.
module Uis
  ROOT = __dir__
  DIR = File.join(ROOT, 'uis')
  DEFAULT = 'classic'
  COOKIE = 'sp_ui'

  # `templates` is a Method (the UI's own `UI<Name>.paths`); the struct answers
  # `paths` with the hash once, so callers never hold a Method object they
  # might mistake for a hash — which is a mistake this round made twice.
  UI = Struct.new(:name, :dir, :title, :design, :words, :templates, keyword_init: true) do
    # The UI's view directory: its pages and its partials. `Library.from`
    # reads `layout.sp` and `partials/` from exactly here, so a UI's frame
    # and its fragments are its own.
    def views = File.join(dir, 'views')

    def paths = @paths ||= templates.call

    # A UI mints its URLs with these substitutions. A path with no `:ui` in
    # it is already absolute and is left alone.
    def path(template, **values)
      template.gsub(':ui', name).gsub(/:([a-z_]+)/) do
        values.fetch(Regexp.last_match(1).to_sym) { raise SlimPickins::Error, "`#{template}` needs a `#{Regexp.last_match(1)}` the UI was not given" }.to_s
      end
    end
  end

  # Every directory that holds a UI, read in name order so the picker and the
  # registry cannot disagree. A UI without an `about.rb` is not a UI — it is
  # an unfinished directory, and it refuses loudly rather than appearing in
  # the picker with nothing behind it.
  def self.all
    @all ||= Dir[File.join(DIR, '*')].select { |path| File.directory?(path) }.sort.map do |dir|
      name = File.basename(dir)
      about = File.join(dir, 'about.rb')
      unless File.file?(about)
        raise SlimPickins::Error, "the UI `#{name}` has no about.rb — a UI is its module API, and without one there is nothing to pick"
      end

      require_relative File.join('uis', name, 'words')
      require_relative File.join('uis', name, 'about')

      ui = UI.new(name: name, dir: dir,
                  title: Object.const_get("UI#{name.capitalize}").const_get(:TITLE),
                  design: Object.const_get("UI#{name.capitalize}").const_get(:DESIGN),
                  words: Object.const_get("#{name.capitalize}Words"),
                  templates: Object.const_get("UI#{name.capitalize}").method(:paths))
      # The words that mint URLs need to know which UI is speaking; the
      # registry is what knows, so it tells them once, as each UI is read.
      StudioUI.current = ui
      ui
    end
  end

  def self.[](name) = all.find { |ui| ui.name == name.to_s }

  # The default UI as an object, for the payloads that mint paths without a
  # request in hand (the census, the boot-time checks). `default` is its name,
  # which is what a route and a cookie want.
  def self.default_ui = (self[DEFAULT] || all.first)

  # A cookie naming a UI that has since been deleted falls back rather than
  # 404s: the studio is a workbench, and a deleted UI is not an error.
  def self.default = default_ui.name

  def self.current(cookies = nil, params = nil)
    asked = params && params[:ui]
    remembered = cookies && cookies[COOKIE]
    chosen = if asked && self[asked] then asked
             elsif remembered && self[remembered] then remembered
             else default
             end
    self[chosen]
  end
end
