module Magicbox::SpecTests
  class Sandbox
    def initialize(thing, mode, code, spec_test_raw)
      @thing         = thing
      @mode          = mode
      @code          = code
      @spec_test_raw = spec_test_raw
      @tmp_dir       = Dir.mktmpdir('magicbox')
      @spec_dir      = File.join(@tmp_dir, 'spec')

      # Placeholders
      @fixtures_dir = '/tmp'
      @test_dir     = '/tmp'
      @extension    = 'rb'
      @module_name  = 'no_module'
      @extra_dirs   = []
      @thing_file   = 'no_thing'

      # Make dirs based on type of test
      autoload_breakdown
      make_temp_dirs(which_dirs(@mode))
      write_fixture_spec
    end

    def run!
      require 'rspec-puppet'
      cmd_out    = Dir.chdir(@tmp_dir) { `rspec --format json` }
      exitstatus = $?.exitstatus
      [exitstatus, cmd_out]
    end

    def cleanup!
      FileUtils.remove_entry_secure(@tmp_dir)
    end

    private

    def autoload_breakdown
      if %w[class define].include?(@mode)
        parts        = @thing.split('::')
        @module_name = parts.shift
        @thing_file  = parts.pop || 'init'
        @extra_dirs  = parts
      else
        @module_name = 'magic_module'
        @thing_file  = @thing
        @extra_dirs  = []
      end
    end

    def spec_template
      <<-"SPEC"
      require 'puppetlabs_spec_helper/module_spec_helper'
      describe '#{@thing}', :type => :#{@mode} do
        #{@spec_test_raw}
      end
      SPEC
    end

    def which_dirs(mode)
      case mode
      when 'function3'
        @fixtures_dir = File.join(@spec_dir, 'fixtures', 'modules', @module_name, 'lib', 'puppet', 'parser', 'functions')
        @test_dir     = File.join(@spec_dir, 'unit', 'functions')
        @mode         = 'puppet_function'
      when 'function4'
        @fixtures_dir = File.join(@spec_dir, 'fixtures', 'modules', @module_name, 'lib', 'puppet', 'functions')
        @test_dir     = File.join(@spec_dir, 'functions')
        @mode         = 'puppet_function'
      when 'class'
        @fixtures_dir = File.join(@spec_dir, 'fixtures', 'modules', @module_name, 'manifests', *@extra_dirs)
        @test_dir     = File.join(@spec_dir, 'unit', 'classes', *@extra_dirs)
        @extension    = 'pp'
      when 'define'
        @fixtures_dir = File.join(@spec_dir, 'fixtures', 'modules', @module_name, 'manifests', *@extra_dirs)
        @test_dir     = File.join(@spec_dir, 'unit', 'defines', *@extra_dirs)
        @extension    = 'pp'
      end
      [@fixtures_dir, @test_dir]
    end

    def make_temp_dirs(path)
      path.each do |p|
        dir_array = p.split(File::SEPARATOR).push(@thing).compact
        dir_array.inject do |memo, part|
          Dir.mkdir(memo) unless memo.empty? || File.exist?(memo)
          File.join(memo, part)
        end
      end
    end

    def write_fixture_spec
      File.open("#{@fixtures_dir}/#{@thing_file}.#{@extension}", 'w') { |file| file.write(@code) }
      File.open("#{@test_dir}/#{@thing_file}_spec.rb", 'w') { |file| file.write(spec_template) }
    end
  end
end
