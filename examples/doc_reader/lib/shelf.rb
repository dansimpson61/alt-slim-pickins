# frozen_string_literal: true

require 'date'

# The documents this repository is explained in, as a reader meets them.
#
# Written on the `conventions-as-principles` branch to exercise the principles:
# every page in this app says as little as it can and lets the domain answer.
# So the domain is where the care goes — what each object is called, how each
# value is presented, and what a collection of them is.
module DocReader
  # The app contract, said once per class. A page asks an object `label_for`
  # and `format_for`; the fixtures answer by hanging a method on each object,
  # and this answers by declaring it on the class the objects share.
  #
  #   labels word_count: 'Words'
  #   formats word_count: :number
  #
  # Called with no arguments, each returns what has been declared — one method,
  # two uses, so there is no separate reader to keep in step with the writer.
  module Described
    def self.included(base) = base.extend(Declarations)

    module Declarations
      def labels(**given) = (@labels ||= {}).merge!(given)
      def formats(**given) = (@formats ||= {}).merge!(given)
    end

    def label_for(attribute) = self.class.labels[attribute.to_sym]
    def format_for(attribute) = self.class.formats[attribute.to_sym]
  end

  Heading = Struct.new(:text, :level, keyword_init: true)

  # One markdown file, and everything a reader might want to know before
  # opening it.
  class Document
    include Described

    labels word_count: 'Words', reading_minutes: 'Minutes', changed_on: 'Last changed'
    formats word_count: :number, reading_minutes: :number

    WORDS_A_MINUTE = 230

    # Who a document is written for. dan's two audiences, and the third thing
    # the repository holds: its own biography, which neither audience should
    # have to read to learn the language.
    FOR_USERS = %w[README.md PRIMER.md VOCABULARY.md].freeze
    HISTORY = /\A(DAYTRIP|ROADMAP|CHRONICLE|LORE)/

    attr_reader :path, :root

    def initialize(path, root)
      @path = path
      @root = root
    end

    def name = File.basename(path)
    def relative = path.delete_prefix("#{root}/")
    def id = relative.delete_suffix('.md').downcase.tr('/', '-')
    def href = "/docs/#{id}"
    def content = @content ||= File.read(path)

    def title = headings.first&.text || name

    def audience
      if FOR_USERS.include?(relative) then 'users'
      elsif relative.start_with?('history/') || name.match?(HISTORY) then 'history'
      else 'devs'
      end
    end

    def for_users? = audience == 'users'
    def history? = audience == 'history'

    def word_count = content.split.size
    def reading_minutes = word_count.fdiv(WORDS_A_MINUTE).ceil
    def long? = reading_minutes > 20
    def changed_on = File.mtime(path).to_date

    def headings
      @headings ||= content.scan(/^(#+)\s+(.+)$/).map do |marks, text|
        Heading.new(text: text.strip, level: marks.size)
      end
    end

    # The chapters: the second-level headings, which is where a reader decides
    # whether to keep going.
    def chapters = headings.select { |heading| heading.level == 2 }
  end

  # A collection of documents that is itself a subject: it answers `each`, so a
  # section over a shelf walks it, and it answers questions about itself, so a
  # metric over a shelf has something to say.
  class Shelf
    include Enumerable
    include Described

    labels total_words: 'Words on the shelf', total_minutes: 'Minutes to read it all',
           history_share: 'Spent on history',
           users: 'For people writing pages', devs: 'For people changing the language',
           history: 'How it came to be'
    formats total_words: :number, total_minutes: :number, history_share: :percent

    ROOT = File.expand_path('../../..', __dir__)

    def self.of(root = ROOT)
      paths = Dir[File.join(root, '*.md')] + Dir[File.join(root, 'history', '*.md')]
      new(paths.sort.map { |path| Document.new(path, root) })
    end

    def initialize(documents) = @documents = documents

    attr_reader :documents

    def each(&) = documents.each(&)
    def size = documents.size
    def empty? = documents.empty?

    def find(id) = documents.find { |document| document.id == id.to_s }

    def matching(query)
      words = query.to_s.downcase.split
      return self if words.empty?

      Shelf.new(select { |document| words.all? { |word| document.content.downcase.include?(word) } })
    end

    def without_history = Shelf.new(reject(&:history?))

    def users = written_for('users')
    def devs = written_for('devs')
    def history = written_for('history')

    def total_words = sum(&:word_count)
    def total_minutes = sum(&:reading_minutes)
    def history_share = history.total_words.fdiv(total_words)

    private

    def written_for(audience) = Shelf.new(select { |document| document.audience == audience })
  end

  # What a reader asked for, and what it found. The form's fields read their
  # values back off it, so a search page re-renders holding what was typed.
  class Query
    include Described

    labels q: 'Words to find', include_history: 'Include the history'

    attr_reader :q, :include_history

    def initialize(shelf, q: '', include_history: false)
      @shelf = shelf
      @q = q
      @include_history = include_history
    end

    def results = (include_history ? @shelf : @shelf.without_history).matching(q)
  end
end
