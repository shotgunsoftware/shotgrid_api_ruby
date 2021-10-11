# typed: false
# frozen_string_literal: true

# Freeze time inside included tests
RSpec.define_context 'with frozen time' do
  around { |tests| Timecop.freeze(Time.current) { tests.run } }

  execute_tests
end
