# frozen_string_literal: true

require_relative 'inference'
require_relative 'generator'

module SlimPickins
  # A named datum bound to a subject: one object answering the four questions
  # every attribute-bearing word asks — `key`, `label`, `value`, and `format`.
  #
  # Precedence is written once here instead of in each word:
  #   - label:  what the sentence said -> what the row/subject's `label_for` said -> English
  #   - format: what `as:` said -> what the row/subject's `format_for` said -> the value's shape
  class KeyValue
    attr_reader :key, :raw_value, :subject, :row, :given_label, :given_format, :given_error

    def initialize(key, raw_value, subject: nil, row: nil, label: nil, format: nil, error: nil, formatted: false)
      @key = key.respond_to?(:to_sym) ? key.to_sym : nil
      @raw_value = raw_value
      @subject = subject
      @row = row
      @given_label = label
      @given_format = format
      @given_error = error
      @formatted = formatted
    end

    def name = @key
    def attribute = @key

    # The human label — the page, then the row or enclosing subject, then English.
    def label
      @given_label || row_or_subject_label || Inference.label(@key)
    end

    # The header or series label — the row, then the enclosing subject.
    def row_or_subject_label
      return nil unless @key

      (@row && @row.label_for(@key)) || (@subject && @subject.label_for(@key))
    end

    # The presentation — `as:`, then the app, then the value's shape.
    def format
      explicit_or_domain_format || Inference.presentation(@raw_value)
    end

    def explicit_or_domain_format
      return @given_format if @given_format
      return nil unless @key

      (@row && @row.format_for(@key)) ||
        (@subject && (@subject.has?(@key) ? @subject.format_for(@key) : nil))
    end

    def value
      @formatted ? formatted_value : @raw_value
    end

    def formatted_value
      Generator.format(explicit_or_domain_format, @raw_value)
    end

    def alignment
      kind = explicit_or_domain_format || Inference.presentation(@raw_value)
      %i[money percent number].include?(kind) ? 'column--numeric' : nil
    end

    def input_type(type_override = nil)
      type_override || (Inference.boolean?(@raw_value) ? :checkbox : Inference.input_type(@raw_value))
    end

    def step(step_override = nil)
      (step_override || Inference.step_for(@raw_value))&.to_s
    end

    # The validation message — `error:`, then the app, then nothing.
    def error
      return @given_error if @given_error
      return nil unless @key && @subject

      subj = @subject.respond_to?(:object) ? @subject.object : @subject
      raw_err = if subj.respond_to?(:error_for)
                  subj.error_for(@key)
                elsif subj.respond_to?(:errors)
                  errs = subj.errors
                  if errs.is_a?(Hash)
                    errs[@key] || errs[@key.to_s]
                  elsif errs.respond_to?(:[])
                    errs[@key] || errs[@key.to_s]
                  end
                end
      raw_err.is_a?(Array) ? raw_err.first : raw_err
    end

    def to_h
      {
        key: @key,
        attribute: @key,
        name: @key,
        label: label,
        value: value,
        raw_value: @raw_value,
        format: format,
        error: error
      }
    end

    # Resolve an attribute-and-value word call (`metric`, `fact`) across all
    # legal sentence forms:
    #   - bare (`metric reading_minutes`, `fact author`)
    #   - dotted (`metric .reading_minutes`, `fact .speech_name`)
    #   - two-argument (`metric reading_minutes, "Minutes"`, `fact status, "Active"`)
    #   - zero-argument when `subject.object` is already a `KeyValue` (`each stat / metric`)
    def self.resolve(subject, args, kwargs, last_fetch: nil, formatted: false)
      fetched_attr, fetched_subj, fetched_val = last_fetch

      if args.empty? && subject.object.is_a?(KeyValue)
        existing = subject.object
        return new(existing.key, existing.raw_value,
                   subject: existing.subject || subject,
                   row: existing.row,
                   label: kwargs[:label] || existing.given_label,
                   format: kwargs[:as] || existing.given_format,
                   formatted: formatted)
      end

      first = args.first
      if first.is_a?(KeyValue)
        second = args[1]
        second = second.call if second.is_a?(Proc)
        return new(first.key, first.raw_value,
                   subject: first.subject || subject,
                   row: first.row,
                   label: kwargs[:label] || second || first.given_label,
                   format: kwargs[:as] || first.given_format,
                   formatted: formatted)
      end

      if first.is_a?(Symbol)
        attr_name = first
        second = args[1]
        second = second.call if second.is_a?(Proc)
        from_fetch = fetched_attr && args.size >= 2 && args[1].equal?(fetched_val)

        if args.size < 2
          raw_val = subject.has?(attr_name) ? subject.fetch(attr_name) : nil
          raw_val = raw_val.call if raw_val.is_a?(Proc)
          label_override = kwargs[:label]
        elsif !from_fetch && second.is_a?(String) && subject.has?(attr_name)
          raw_val = subject.fetch(attr_name)
          raw_val = raw_val.call if raw_val.is_a?(Proc)
          label_override = kwargs[:label] || second
        else
          raw_val = second
          label_override = kwargs[:label]
        end

        new(attr_name, raw_val,
            subject: subject,
            row: (fetched_subj if from_fetch),
            label: label_override,
            format: kwargs[:as],
            formatted: formatted)
      else
        attr_name = (fetched_attr if args.any? && args[0].equal?(fetched_val))
        raw_val = first.is_a?(Proc) ? first.call : first
        label_override = kwargs[:label] || args[1]

        new(attr_name, raw_val,
            subject: subject,
            row: (fetched_subj if attr_name),
            label: label_override,
            format: kwargs[:as],
            formatted: formatted)
      end
    end

    # Resolve a form control (`field`, `input`, `textarea`, `checkbox`, `choice`, `hidden`).
    def self.for_control(subject, args, kwargs = {}, second_is: :label, require_attribute: true)
      sym = args.find { |a| a.is_a?(Symbol) }
      non_sym = args.find { |a| !a.nil? && !a.is_a?(Symbol) }

      if second_is == :value
        raw_val = non_sym.nil? ? (sym ? subject.fetch(sym) : nil) : non_sym
        new(sym, raw_val, subject: subject, label: kwargs[:label], error: kwargs[:error])
      elsif sym
        raw_val = if require_attribute
                    subject.fetch(sym)
                  else
                    subject.has?(sym) ? subject.fetch(sym) : nil
                  end
        new(sym, raw_val, subject: subject, label: kwargs[:label] || non_sym, error: kwargs[:error])
      else
        new(nil, args[0], subject: subject, label: kwargs[:label] || args[1], error: kwargs[:error])
      end
    end

    # Shared indifferent key lookup for Hash-backed subjects and `Dictionary`.
    def self.key_candidates(key, predicate: false)
      candidates = [key]
      if key == true || key == :true || key == 'true'
        candidates = [true, :true, 'true']
      elsif key == false || key == :false || key == 'false'
        candidates = [false, :false, 'false']
      elsif key.nil? || key == :nil || key == 'nil'
        candidates = [nil, :nil, 'nil']
      else
        candidates << key.to_sym if key.respond_to?(:to_sym)
        candidates << key.to_s if key.respond_to?(:to_s)
        if predicate && key.to_s.end_with?('?')
          base = key.to_s.chomp('?')
          candidates << base.to_sym
          candidates << base
        end
      end
      candidates.uniq
    end

    def self.hash_has?(hash, key, predicate: false)
      return false unless hash.is_a?(Hash)

      key_candidates(key, predicate: predicate).any? { |k| hash.key?(k) }
    end

    def self.hash_fetch(hash, key, predicate: false)
      return nil unless hash.is_a?(Hash)

      key_candidates(key, predicate: predicate).each do |k|
        return hash[k] if hash.key?(k)
      end
      nil
    end
  end
end
