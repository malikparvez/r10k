require 'r10k/logging'
require "puppetfile-resolver"
require "puppetfile-resolver/puppetfile/parser/r10k_eval"
require 'r10k/util/resolver'

module R10K
  module Action
    module Puppetfile
      class Resolve < R10K::Action::Base
        include R10K::Logging

        def call
          options = { basedir: @root }

          loader = R10K::ModuleLoader::Puppetfile.new(**options)
          begin
            $stderr.puts _("\nGenerating Resolved Puppetfile...\n")
            response = R10K::Util::Resolver.new(loader.puppetfile_path).resolve 

            if response
              $stderr.puts _("\nPuppetfile Resolved Successfully.\n")
            else
              $stderr.puts _("\nFailed to resolve Puppetfile.\n")
            end
          rescue => e
            $stderr.puts R10K::Errors::Formatting.format_exception(e, @trace)
            false
          end
        end

        private

        def allowed_initialize_opts
          super.merge(root: :self, puppetfile: :self, moduledir: :self)
        end
      end
    end
  end
end

