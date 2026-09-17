# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# The gathering road, walked (dan's ruling, 2026-09-17).
#
# The vocabulary's gathering — `table`/`column`, `chart`/`line`, `choose`/`when`,
# `choice`/`option` — is Ruby words registering into Ruby gatherers, and it works.
# The *road by which an app writes a gatherer in the language* was closed in two
# places and had no user, which is why nobody noticed: `inside:` could never
# resolve, because `open_gatherer_named` matches `g.word` and **no Word instance
# answered `word`**, and `Builder#render_partial` — the other half of the road —
# was dead code naming a constant that does not exist.
#
# The repairs: `render_partial` deleted, `Word#word` added, and a `.sp` partial
# may now gather and be registered into. These tests are the pin dan asked for —
# without one the road closes again the moment nothing walks it.
class GatheringRoadTest < Minitest::Test
  GATHERER = "expects children: any, takes: gathers, shape: encloses\n\nbox\n  children\n"
  REGISTRAR = "expects content: true, inside: my_gatherer, shape: registers\n\ntext .content\n"

  def library
    SlimPickins::Library.new(partials: { my_gatherer: GATHERER, my_row: REGISTRAR })
  end

  def render(source)
    SlimPickins.render(source, path: 'road.sp', locals: {}, library: library)
  end

  # The whole point: what registers is collected, then spliced where the
  # gatherer says `children` — not left where it was written.
  def test_a_partial_gatherer_collects_the_partials_that_register_into_it
    html = render("page \"P\"\n  my_gatherer\n    my_row \"first\"\n    my_row \"second\"\n")

    assert_includes html,
                    '<div class="box my_gatherer"><p class="text my_row">first</p>' \
                    '<p class="text my_row">second</p></div>'
  end

  def test_a_registrar_outside_its_gatherer_is_refused
    error = assert_raises(SlimPickins::Error) { render("page \"P\"\n  my_row \"x\"\n") }

    assert_match(/belongs inside `my_gatherer`/, error.message)
  end

  # The hinge. `open_gatherer_named` finds a gatherer by its word name, and
  # before this no word instance could be found — the finder's candidate list
  # was empty by construction. A named word derives its name from its class; a
  # partial's class is anonymous (`Class.new(PartialWord)`), so it answers with
  # the name the Library gave it.
  def test_every_word_answers_its_own_name
    assert_equal :table, SlimPickins::Words::Table.new(nil, [:rows], {}, nil).word

    library # compiling the partials registers them
    partial = SlimPickins::Word.registry.fetch(:my_gatherer)

    assert_equal :my_gatherer, partial.new(nil, [], {}, nil).word
  end

  # And the Ruby road still runs, unchanged: a page word registering into a Ruby
  # gatherer by class.
  def test_the_built_in_gathering_is_untouched
    html = SlimPickins.render("page \"P\"\n  table rows\n    column name\n",
                              locals: { rows: [{ name: 'x' }] })

    assert_includes html, '<th>Name</th>'
    assert_includes html, '<td>x</td>'
  end
end
