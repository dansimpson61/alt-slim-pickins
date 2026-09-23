# frozen_string_literal: true

require 'cgi'
require_relative '../lib/slim_pickins'
require_relative '../lib/slim_pickins/conventions'
require_relative '../lib/slim_pickins/contracts'

# The Combined Inspection Surface: The Semantic Tree & The Why Pane.
#
# Fulfills Win W3 of DAYTRIP-0.4.0c:
# - Semantic Tree (What): The parsed AST hierarchy returned by `SlimPickins.evaluate`.
# - Provenance & Why Pane (Why): The 4-tier decision trail (`page`, `app`, `language`, `theme`),
#   conventions from `SlimPickins::Conventions::ALL`, and override idioms.
module StudioInspector
  module_function

  def page_for(tree, source: '')
    nodes_data = []
    tree_html = render_node_tree(tree, nodes_data, prefix: 'n')

    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Inspect</title>
        <link rel="stylesheet" href="/assets/slim-pickins.css">
        <style>
          body {
            margin: 0;
            padding: 0.5rem;
            font-family: var(--face-sans, system-ui, sans-serif);
            color: var(--ink, #18181b);
            background: var(--surface, #ffffff);
            height: 100vh;
            box-sizing: border-box;
            overflow: hidden;
          }
          .inspector {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.75rem;
            height: calc(100vh - 1rem);
          }
          @media (max-width: 720px) {
            .inspector {
              grid-template-columns: 1fr;
              grid-template-rows: 1fr 1fr;
            }
          }
          .inspector__pane {
            border: var(--rule-width, 1px) solid var(--rule, #e4e4e7);
            border-radius: var(--radius, 6px);
            background: var(--surface-soft, #fafafa);
            overflow-y: auto;
            padding: 0.75rem;
            min-height: 0;
            display: flex;
            flex-direction: column;
          }
          .pane-header {
            margin: 0 0 0.5rem 0;
            padding-bottom: 0.5rem;
            border-bottom: var(--rule-width, 1px) solid var(--rule, #e4e4e7);
            font-size: var(--size-base, 1rem);
            font-weight: var(--weight-bold, 600);
            display: flex;
            align-items: center;
            justify-content: space-between;
          }
          .pane-content {
            flex-grow: 1;
            overflow-y: auto;
          }
          .tree-list {
            list-style: none;
            padding-left: 0;
            margin: 0;
          }
          .tree-item {
            margin: 0.2rem 0;
            font-family: var(--face-mono, monospace);
            font-size: var(--size-small, 0.85rem);
          }
          .tree-item details {
            margin-left: 1rem;
          }
          .tree-item > details {
            margin-left: 0;
          }
          .node-summary {
            cursor: pointer;
            padding: 0.25rem 0.4rem;
            border-radius: var(--radius, 4px);
            display: flex;
            align-items: center;
            gap: 0.4rem;
            user-select: none;
            transition: background 0.15s ease;
          }
          .node-summary:hover {
            background: var(--surface-dim, #f4f4f5);
          }
          .node-summary.selected {
            background: var(--surface-tint, #e0f2fe);
            outline: 1px solid var(--accent, #0284c7);
          }
          .node-type {
            font-weight: bold;
            color: var(--ink, #18181b);
          }
          .node-variant {
            color: var(--accent, #0284c7);
          }
          .node-preview {
            color: var(--ink-faint, #71717a);
            font-size: 0.8em;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            max-width: 18ch;
          }
          .node-chip {
            font-size: 0.7em;
            background: var(--surface, #ffffff);
            border: 1px solid var(--rule, #e4e4e7);
            padding: 0.1rem 0.3rem;
            border-radius: 3px;
            color: var(--ink-soft, #52525b);
          }
          .detail-card {
            display: none;
          }
          .detail-card.active {
            display: block;
          }
          .detail-title {
            font-size: 1.1rem;
            margin: 0 0 0.5rem 0;
            display: flex;
            align-items: center;
            gap: 0.5rem;
          }
          .table-title {
            font-size: 0.85rem;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--ink-soft, #71717a);
            margin: 0.75rem 0 0.25rem 0;
          }
          .attr-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.82rem;
            font-family: var(--face-mono, monospace);
            background: var(--surface, #ffffff);
            border: 1px solid var(--rule, #e4e4e7);
            border-radius: var(--radius, 4px);
            margin-bottom: 0.75rem;
          }
          .attr-table th, .attr-table td {
            text-align: left;
            padding: 0.35rem 0.5rem;
            border-bottom: 1px solid var(--rule, #f4f4f5);
          }
          .attr-table th {
            color: var(--ink-soft, #71717a);
            width: 32%;
            background: var(--surface-soft, #fafafa);
          }
          .convention-item {
            background: var(--surface, #ffffff);
            border: 1px solid var(--rule, #e4e4e7);
            border-radius: var(--radius, 4px);
            padding: 0.5rem;
            margin-bottom: 0.5rem;
          }
          .convention-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 0.25rem;
          }
          .convention-name {
            font-family: var(--face-mono, monospace);
            font-weight: bold;
            font-size: 0.85rem;
          }
          .convention-badge {
            font-size: 0.7rem;
            text-transform: uppercase;
            padding: 0.1rem 0.35rem;
            border-radius: 3px;
            font-weight: 600;
          }
          .tier-structural { background: #e0e7ff; color: #3730a3; }
          .tier-shape { background: #fef3c7; color: #92400e; }
          .tier-domain { background: #dcfce7; color: #166534; }
          .tier-axiomatic { background: #f3e8ff; color: #6b21a8; }
          .convention-decides {
            font-size: 0.85rem;
            color: var(--ink, #18181b);
            margin: 0.2rem 0;
          }
          .convention-override {
            margin-top: 0.35rem;
            font-size: 0.8rem;
          }
          .override-label {
            color: var(--ink-soft, #71717a);
            font-size: 0.75rem;
            text-transform: uppercase;
          }
          .override-code {
            font-family: var(--face-mono, monospace);
            background: var(--surface-soft, #f4f4f5);
            padding: 0.15rem 0.35rem;
            border-radius: 3px;
            display: inline-block;
            margin-top: 0.1rem;
          }
          .empty-note {
            color: var(--ink-soft, #71717a);
            font-style: italic;
            font-size: 0.85rem;
          }
        </style>
      </head>
      <body>
        <div class="inspector">
          <div class="inspector__pane">
            <div class="pane-header">
              <span>Semantic Tree</span>
              <span class="node-chip">#{nodes_data.size} nodes</span>
            </div>
            <div class="pane-content">
              #{tree_html}
            </div>
          </div>
          <div class="inspector__pane">
            <div class="pane-header">
              <span>Provenance &amp; The Why Pane</span>
              <span class="node-chip">4-tier precedence</span>
            </div>
            <div class="pane-content">
              #{render_details(nodes_data)}
            </div>
          </div>
        </div>
        <script>
          function selectNode(id) {
            document.querySelectorAll('.node-summary').forEach(el => el.classList.remove('selected'));
            document.querySelectorAll('.detail-card').forEach(el => el.classList.remove('active'));
            const summary = document.getElementById('sum-' + id);
            if (summary) summary.classList.add('selected');
            const card = document.getElementById('card-' + id);
            if (card) card.classList.add('active');
          }
          document.addEventListener('DOMContentLoaded', () => {
            const first = document.querySelector('.node-summary');
            if (first && first.id) {
              selectNode(first.id.replace('sum-', ''));
            }
          });
        </script>
      </body>
      </html>
    HTML
  end

  def error_page_for(error)
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="utf-8">
        <link rel="stylesheet" href="/assets/slim-pickins.css">
        <style>
          body { padding: 1.5rem; font-family: var(--face-sans, sans-serif); }
          .refusal {
            background: #fef2f2;
            border: 1px solid #fecaca;
            border-radius: 6px;
            padding: 1rem;
            color: #991b1b;
          }
          .refusal h2 { margin-top: 0; font-size: 1.1rem; }
          .refusal pre { font-family: var(--face-mono, monospace); white-space: pre-wrap; font-size: 0.85rem; }
        </style>
      </head>
      <body>
        <div class="refusal">
          <h2>Refusal / Evaluation Error</h2>
          <pre>#{CGI.escapeHTML(error.message)}</pre>
        </div>
      </body>
      </html>
    HTML
  end

  def render_node_tree(nodes, collector, prefix: 'n')
    return '<p class="empty-note">Empty tree</p>' if nodes.nil? || nodes.empty?

    html = +%(<ul class="tree-list">\n)
    nodes.each_with_index do |node, index|
      id = "#{prefix}_#{index}"
      html << render_single_node(node, collector, id)
    end
    html << %(</ul>\n)
    html
  end

  def render_single_node(node, collector, id)
    return '' unless node.is_a?(Array) && !node.empty?

    unless node.first.is_a?(Symbol)
      return node.map.with_index { |child, i| render_single_node(child, collector, "#{id}_#{i}") }.join("\n")
    end

    type = node[0]
    attrs = node[1] || {}
    raw_children = node[2] || []

    word_name = (attrs[:class_base] || type).to_sym
    contract = SlimPickins::CONTRACTS[word_name]
    infers = contract&.infers || []
    conventions = infers.map { |c| SlimPickins::Conventions::ALL.find { |cv| cv.name == c } }.compact

    # Gather rows as children if table
    children = raw_children
    if type == :table && attrs[:rows].is_a?(Array) && children.empty?
      children = attrs[:rows]
    end

    preview = attrs[:body] || attrs[:heading] || attrs[:name] || attrs[:variant]
    preview_str = preview ? CGI.escapeHTML(preview.to_s) : nil

    collector << {
      id: id,
      type: type,
      word: word_name,
      attrs: attrs,
      conventions: conventions,
      preview: preview_str
    }

    has_children = children.is_a?(Array) && !children.empty?

    html = +%(<li class="tree-item">\n)
    if has_children
      html << %(<details open>\n)
      html << %(  <summary class="node-summary" id="sum-#{id}" onclick="selectNode('#{id}')">\n)
      html << %(    <span class="node-type">:#{type}</span>\n)
      html << %(    <span class="node-variant">#{CGI.escapeHTML(word_name.to_s)}</span>\n) if word_name != type
      html << %(    <span class="node-preview">"#{preview_str}"</span>\n) if preview_str
      html << %(    <span class="node-chip">#{conventions.size} why</span>\n) if conventions.any?
      html << %(  </summary>\n)
      html << %(  <ul class="tree-list">\n)
      children.each_with_index do |child, c_idx|
        html << render_single_node(child, collector, "#{id}_#{c_idx}")
      end
      html << %(  </ul>\n)
      html << %(</details>\n)
    else
      html << %(<div class="node-summary" id="sum-#{id}" onclick="selectNode('#{id}')">\n)
      html << %(  <span class="node-type">:#{type}</span>\n)
      html << %(  <span class="node-variant">#{CGI.escapeHTML(word_name.to_s)}</span>\n) if word_name != type
      html << %(  <span class="node-preview">"#{preview_str}"</span>\n) if preview_str
      html << %(  <span class="node-chip">#{conventions.size} why</span>\n) if conventions.any?
      html << %(</div>\n)
    end
    html << %(</li>\n)
    html
  end

  def render_details(nodes_data)
    return '<p class="empty-note">No nodes to inspect.</p>' if nodes_data.empty?

    html = +''
    nodes_data.each_with_index do |data, index|
      active_class = index.zero? ? ' active' : ''
      html << %(<div class="detail-card#{active_class}" id="card-#{data[:id]}">\n)
      html << %(  <div class="detail-title">\n)
      html << %(    <strong>:#{data[:type]}</strong>\n)
      html << %(    <span class="node-variant">#{data[:word]}</span>\n)
      html << %(  </div>\n)

      # Attributes table
      html << %(  <div class="table-title">Node Attributes</div>\n)
      html << %(  <table class="attr-table">\n)
      data[:attrs].each do |k, v|
        next if %i[rows columns foot].include?(k) # complex nested payloads displayed separately

        val_str = v.nil? ? 'nil' : CGI.escapeHTML(v.inspect)
        html << %(    <tr><th>#{CGI.escapeHTML(k.to_s)}</th><td>#{val_str}</td></tr>\n)
      end
      html << %(  </table>\n)

      # Conventions
      html << %(  <div class="table-title">Inference Decisions &amp; Conventions</div>\n)
      if data[:conventions].empty?
        html << %(  <p class="empty-note">No conventions declared for this word.</p>\n)
      else
        data[:conventions].each do |conv|
          tier_class = "tier-#{conv.grade}"
          tier_owner = case conv.grade
                       when :domain then 'App Contract'
                       when :shape then 'Language (Shape)'
                       when :structural then 'Language (Structure)'
                       when :axiomatic then 'Theme'
                       else 'Language'
                       end

          html << %(  <div class="convention-item">\n)
          html << %(    <div class="convention-header">\n)
          html << %(      <span class="convention-name">:#{conv.name}</span>\n)
          html << %(      <span class="convention-badge #{tier_class}">#{tier_owner}</span>\n)
          html << %(    </div>\n)
          html << %(    <div class="convention-decides">#{CGI.escapeHTML(conv.decides)}</div>\n)
          html << %(    <div class="convention-override">\n)
          html << %(      <div class="override-label">When Silent:</div>\n)
          html << %(      <div>#{CGI.escapeHTML(conv.when_silent)}</div>\n)
          html << %(      <div class="override-label" style="margin-top: 0.2rem;">Override Idiom:</div>\n)
          html << %(      <span class="override-code">#{CGI.escapeHTML(conv.override)}</span>\n)
          html << %(    </div>\n)
          html << %(  </div>\n)
        end
      end

      html << %(</div>\n)
    end
    html
  end
end
