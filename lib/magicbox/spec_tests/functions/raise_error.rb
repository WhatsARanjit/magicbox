module Magicbox::Spec_tests::Functions
  class Raise_error
    def self.make_spec(function_args, value)
      "it { is_expected.to run.with_params(#{function_args}).and_raise_error(#{value}) }"
    end
  end
end
