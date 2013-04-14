require 'r10k/cli'
require 'r10k/puppetfile'

require 'cri'

module R10K::CLI
  module Puppetfile
    def self.command
      @cmd ||= Cri::Command.define do
        name    'puppetfile'
        usage   'puppetfile <subcommand>'
        summary 'Perform operations on a Puppetfile'

        run do |opts, args, cmd|
          puts cmd.help
          exit 0
        end
      end
    end

    module Install
      def self.command
        @cmd ||= Cri::Command.define do
          name    'install'
          usage   'install'
          summary 'Install all modules from a Puppetfile'

          run do |opts, args, cmd|
            puppetfile_root = Dir.getwd
            puppetfile_path = ENV['PUPPETFILE_DIR']
            puppetfile      = ENV['PUPPETFILE']

            puppetfile = R10K::Puppetfile.new(puppetfile_root, puppetfile_path, puppetfile)
            puppetfile.load

            puppetfile.modules.each do |mod|
              mod.sync
            end

            exit 0
          end
        end
      end
    end
    self.command.add_command(Install.command)
  end
  self.command.add_command(Puppetfile.command)
end
