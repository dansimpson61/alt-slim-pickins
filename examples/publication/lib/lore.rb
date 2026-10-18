# frozen_string_literal: true

require 'date'

module Publication
  # One dated log record — a lesson, not a document. Its body is markdown; its
  # words are the vocabulary terms it mentions. A reader meets it the way it
  # meets a document: a title (the entry's first sentence), a small cluster of
  # facts, and the prose.
  Entry = Struct.new(:id, :date, :author, :title, :body, :words, :tags, keyword_init: true) do
    WORDS_A_MINUTE = 230

    def reading_minutes = body.to_s.split.size.fdiv(WORDS_A_MINUTE).ceil
  end

  class Lore
    KNOWN_WORDS = %w[
      page section card box article grid list table form field input
      choice checkbox radio button submit link nav tabs tab scroll
      heading paragraph span prose markdown code snippet quote callout
      badge metric chart time money number text item details summary
      disclosure actions empty otherwise each image figure figcaption
      timeline entry step
    ].freeze

    attr_reader :path

    def self.default_path
      File.expand_path('../../../LORE.md', __dir__)
    end

    def self.load(path = default_path)
      new(path).load!
    end

    def initialize(path = self.class.default_path)
      @path = path
      @entries = nil
    end

    def load!
      content = File.read(@path)
      @entries = parse(content)
      self
    end

    def entries
      load! unless @entries
      @entries
    end

    def all
      entries
    end

    def find(id)
      entries.find { |e| e.id == id.to_s }
    end

    def search(query)
      q = query.to_s.strip.downcase
      return all if q.empty?

      all.select do |e|
        e.title.downcase.include?(q) ||
          e.body.downcase.include?(q) ||
          e.author.downcase.include?(q) ||
          e.date.to_s.include?(q) ||
          e.words.any? { |w| w.downcase.include?(q) }
      end
    end

    def by_author(author)
      all.select { |e| e.author.downcase == author.to_s.strip.downcase }
    end

    def stats
      authors = all.map(&:author).tally
      all_words = all.flat_map(&:words).tally
      {
        total_entries: all.size,
        distinct_authors: authors.size,
        authors_tally: authors,
        top_words: all_words.sort_by { |_, count| -count }.first(8).to_h,
        first_date: all.map(&:date).min,
        last_date: all.map(&:date).max
      }
    end

    private

    def parse(markdown)
      parsed = []
      # LORE entries start with `## YYYY-MM-DD — Author`
      chunks = markdown.split(/^## /)
      # First chunk is the header intro
      chunks.drop(1).each_with_index do |chunk, index|
        lines = chunk.lines
        header = lines.first.strip
        full_body = lines.drop(1).join.strip
        next if header.empty? || full_body.empty?

        # Parse `YYYY-MM-DD — Author`
        parts = header.split(/\s*—\s*/, 2)
        date_str = parts.first.strip
        author_str = parts[1]&.strip || 'Unknown'

        # The title is the first sentence, and the body is the rest — so the
        # page speaks the title once (as its `<h1>`) and `prose` begins after
        # it, exactly as a self-titling document drops its leading heading.
        sentences = full_body.split(/(?<=[.?!])\s+/)
        first_sentence = sentences.first.to_s.strip
        # Clean title if too long or markdown chars
        title = first_sentence.gsub(/[`*#]/, '').strip
        title = title[0..80] + '...' if title.size > 83
        rest = sentences.drop(1).join(' ').strip
        body = rest.empty? ? full_body : rest

        # Mentioned words in backticks or text matching KNOWN_WORDS, read from
        # the whole entry — the title sentence may name one too.
        backticked = full_body.scan(/`([a-z_?:]+)`/).flatten.uniq
        words = backticked.select { |w| KNOWN_WORDS.include?(w.sub(/[:?]\z/, '')) }

        id = "#{date_str}-#{index + 1}"

        parsed << Entry.new(
          id: id,
          date: date_str,
          author: author_str,
          title: title,
          body: body,
          words: words,
          tags: words
        )
      end

      parsed
    end
  end
end
