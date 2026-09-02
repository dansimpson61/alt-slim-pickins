require 'minitest/autorun'
require_relative '../lib/slim_pickins'

# An app word that IS a gatherer, built with the public surface alone: the
# page declares photos, the word collects them, then renders the grid. This
# is the proof that the gatherer mechanism — the thing only table, chart,
# choose and choice used to own — is now food any word may eat.
class AppGathererTest < Minitest::Test
  class Gallery < SlimPickins::Component
    INSIDE = 'a gallery'

    def render
      with_open
      emit_node([:grid, { variant: :gallery }, @collected])
    end
  end

  module Words
    def gallery(&block) = Gallery.new(self, &block).render

    def photo(*args)
      _, src = arguments(args)
      register!(Gallery,
                element(:img, { class: token(:photo), src: src }, []),
                'photo')
    end
  end

  def test_an_app_word_can_be_a_gatherer
    html = SlimPickins.render("page p\n  gallery\n    photo .url\n    photo .url\n",
                              locals: { p: { url: '/t/1.png' } },
                              library: SlimPickins::Library.new(words: Words))
    assert_includes html, '<div class="grid grid--gallery">'
    assert_equal 2, html.scan('<img class="photo"').size
  end

  def test_a_photo_outside_a_gallery_is_refused_like_any_registering_word
    error = assert_raises(SlimPickins::Error) do
      SlimPickins.render("page p\n  photo .url\n", locals: { p: { url: '/t.png' } },
                         library: SlimPickins::Library.new(words: Words))
    end
    assert_match(/\Aphoto belongs inside a gallery\n/, error.message)
  end
end
