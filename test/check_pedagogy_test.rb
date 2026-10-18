# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../checkers/check_pedagogy'

class CheckPedagogyTest < Minitest::Test
  def test_the_real_author_guides_pass_pedagogy_check
    findings = PedagogyChecker.run
    assert_empty findings, "PedagogyChecker found #{findings.size} problems:\n#{findings.map(&:to_s).join("\n")}"
  end

  def test_page_spoken_in_sp_template_is_refused
    snippet = "page portfolio\n  section accounts\n"
    findings = PedagogyChecker.verify_fence('test.md', snippet, 1, '', '')
    assert findings.any? { |f| f.kind == :plane_violation },
           "Expected plane_violation for `page` in .sp, got #{findings.map(&:kind)}"
  end

  def test_frame_without_page_is_a_shell_and_passes
    snippet = "nav\n  link home\ncontents\nfooter 'fine'\n"
    findings = PedagogyChecker.verify_fence('test.md', snippet, 1, 'frame', '')
    refute findings.any? { |f| f.kind == :frame_missing_page },
           "A shell frame has no `page`; got #{findings.map(&:kind)}"
  end

  def test_page_spoken_in_frame_is_refused
    snippet = "page 'Doc'\n  contents\n"
    findings = PedagogyChecker.verify_fence('test.md', snippet, 1, 'frame', '')
    assert findings.any? { |f| f.kind == :plane_violation },
           "Expected plane_violation for `page` in .frame, got #{findings.map(&:kind)}"
  end

  def test_frame_missing_contents_is_refused
    snippet = "'Doc'\n  nav\n    link home\n"
    findings = PedagogyChecker.verify_fence('test.md', snippet, 1, 'frame', '')
    assert findings.any? { |f| f.kind == :frame_missing_contents },
           "Expected frame_missing_contents, got #{findings.map(&:kind)}"
  end

  def test_box_with_multiple_arguments_is_refused
    snippet = "def catalog documents, title\n  box documents, title\n"
    findings = PedagogyChecker.verify_fence('test.md', snippet, 1, 'sp', '')
    assert findings.any? { |f| f.kind == :box_multi_arg },
           "Expected box_multi_arg, got #{findings.map(&:kind)}"
  end

  def test_archaic_comma_after_def_is_refused
    snippet = "def catalog, documents, title\n  section documents, title\n"
    findings = PedagogyChecker.verify_fence('test.md', snippet, 1, 'sp', '')
    assert findings.any? { |f| f.kind == :archaic_def },
           "Expected archaic_def, got #{findings.map(&:kind)}"
  end
end
