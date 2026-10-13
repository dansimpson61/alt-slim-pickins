# frozen_string_literal: true

require 'minitest/autorun'

class IsolationTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  LIB = File.join(ROOT, 'lib')

  def test_standalone_gem_execution_in_isolated_process
    # Execute a pristine Ruby process whose LOAD_PATH contains ONLY lib.
    # No access to test/, studio/, examples/, or harness scripts.
    script = <<~RUBY
      root = #{ROOT.inspect}
      $LOAD_PATH.reject! { |p| p.start_with?(root) }
      $LOAD_PATH.unshift(#{LIB.inspect})

      require 'slim_pickins'

      # Check version
      raise 'VERSION mismatch' unless SlimPickins::VERSION == '0.6.0'

      # Render a template exercising both primitives and canonical partials
      template = <<~SP
        page "Isolated"
          section "Account Overview"
            card
              title "Balance"
              money .balance
      SP

      html = SlimPickins.render(template, locals: { balance: 4250 })
      raise 'Missing page title' unless html.include?('<title>Isolated</title>')
      raise 'Missing card class' unless html.include?('class="card"')
      raise 'Missing money class' unless html.include?('class="money"')

      # Compile Spiff styles
      spiff_src = <<~SPIFF
        surface isolated
          stage
            air generous
      SPIFF
      css = SlimPickins::Spiff.compile(spiff_src)
      raise 'Missing compiled container rule' unless css.include?('container-name: isolated;')

      # Verify boundary isolation: no studio, app, census, or test leak
      forbidden = %w[Studio StudioDocs StudioPages StudioStatus StudioInspector
                     DocReader LoreReader Portfolio Roth WayExam MilestonePlanner
                     WordGraph Vitals]
      leaked = forbidden.select { |name| Object.const_defined?(name) }
      raise "Leaked modules: \#{leaked.join(', ')}" unless leaked.empty?

      print 'ISOLATION_OK'
    RUBY

    output = IO.popen(['ruby', '-e', script], &:read)
    assert_equal 'ISOLATION_OK', output
  end
end
