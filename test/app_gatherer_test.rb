require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# An app word that IS a gatherer, built with the public surface alone: the
# page declares thumbs, the word collects them, then renders the grid. This
# is the proof that the gatherer mechanism — the thing only table, chart,
# choose and choice used to own — is now food any word may eat.
class AppGathererTest < Minitest::Test
  class Thumbnails < SlimPickins::Component
    INSIDE = 'a thumbnails'

    def render
      with_open
      emit_node([:grid, { variant: :thumbnails }, @collected])
    end
  end

  module Words
    def thumbnails(&block) = Thumbnails.new(self, &block).render

    def thumb(*args)
      _, src = arguments(args)
      register!(Thumbnails,
                element(:img, { class: token(:thumb), src: src }, []),
                'thumb')
    end
  end

  def test_an_app_word_can_be_a_gatherer
    html = SlimPickins.render("page p\n  thumbnails\n    thumb .url\n    thumb .url\n",
                              locals: { p: { url: '/t/1.png' } },
                              library: SlimPickins::Library.new(words: Words))
    assert_includes html, '<div class="grid grid--thumbnails">'
    assert_equal 2, html.scan('<img class="thumb"').size
  end

  def test_a_thumb_outside_a_thumbnails_is_refused_like_any_registering_word
    error = assert_raises(SlimPickins::Error) do
      SlimPickins.render("page p\n  thumb .url\n", locals: { p: { url: '/t.png' } },
                         library: SlimPickins::Library.new(words: Words))
    end
    assert_match(/\Athumb belongs inside a thumbnails\n/, error.message)
  end
end
