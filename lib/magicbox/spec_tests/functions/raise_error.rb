module Magicbox::Spec_tests::Functions
  class Raise_error
    def self.make_spec(*opts)
      opts_hash     = opts.to_h
      function_args = opts_hash[:function_args]
      value         = opts_hash[:value]

      "it { is_expected.to run.with_params(#{function_args}).and_raise_error(#{value}) }"
    end
  end
end
