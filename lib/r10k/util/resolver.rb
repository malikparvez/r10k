require 'r10k/logging'
require 'r10k/errors/formatting'

module R10K
  module Util
    class Resolver
      include R10K::Logging
      attr_accessor :source
    
      def initialize(source)
        @source = source
        @output = File.open('ResolvedPuppetfile', 'w+')
      end

      def resolve
        begin
          content = File.read(source)
          puppetfile = PuppetfileResolver::Puppetfile::Parser::R10KEval.parse(content)

          # Make sure the Puppetfile is valid
          unless puppetfile.valid?
            $stderr.puts _("Puppetfile source is not valid")
            puppetfile.validation_errors.each { |err| logger.error(err) }
            return false
          end

          resolver = PuppetfileResolver::Resolver.new(puppetfile, nil)
          result = resolver.resolve(strict_mode: true)
          
          # copy over the existing Puppetfile, then add resolved dependencies below
          @output.write(puppetfile.content)
          @output.write("\n\n####### resolved dependencies #######\n\n")
          
          result.dependency_graph.each do |dep|
            # ignore the original modules, they're already in the output
            next if puppetfile.modules.find { |mod| mod.name == dep.name }
          
            mod = dep.payload
            next unless mod.is_a?(PuppetfileResolver::Models::ModuleSpecification)
          
            @output.write("mod '#{dep.payload.owner}-#{dep.payload.name}', '#{dep.payload.version}'\n")
          end
        
          @output.write("\n# Generated with r10k\n")

          logger.warn(
            "Please inspect the output to ensure you know what you are deploying in your infrastructure."
          )

        rescue PuppetfileResolver::Puppetfile::DocumentVersionConflictError => e
          $stderr.puts _("DocumentVersionConflictError: #{e.message}")
        rescue Molinillo::VersionConflict => e
          $stderr.puts _("VersionConflict: #{e.message}")
        rescue => e
          $stderr.puts _("An unexpected error occurred: #{e.message}")
        end
      end
    end
  end
end
