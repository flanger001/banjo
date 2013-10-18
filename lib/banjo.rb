require 'banjo/version'

require 'eventmachine'
require 'unimidi'

require 'banjo/channel'

$: << '.'

module Banjo
  class << self
    attr_accessor :tempo
    attr_accessor :ticks_per_period
  end

  def self.load_channels
    Dir['./channels/*.rb'].each do |file|
      load file
    end
  end

  def self.play
    tempo_in_ms = 60.0 / Banjo.tempo / ticks_per_period

    EventMachine.run do
      n = 0
      EM.add_periodic_timer(tempo_in_ms) do
        begin
          Banjo.load_channels
        end

        Banjo::Channel.channels.each do |klass|
          channel = klass.new(n)
          channel.perform
        end

        n < (ticks_per_period - 1) ? n += 1 : n = 0
      end

      puts "Banjo Reactor started..."
    end
  end
end
