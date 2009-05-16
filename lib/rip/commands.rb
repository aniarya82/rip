module Rip
  module Commands
    extend self

    def help(*args)
      puts "Usage: rip COMMAND [options]", ""
      puts "Commands available:"

      instance_methods.each do |method|
        puts "  #{method}"
      end
    end

    def install(options = {}, *args)
    end

    def uninstall(options = {}, *args)
    end

    def env(options, command, *args)
      Rip::Env.new.call(command, *args)
    end
  end
end