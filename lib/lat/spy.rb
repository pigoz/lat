module Lat
  class Spy
    def initialize(&condition)
      @mutex = Mutex.new
      @resource = ConditionVariable.new
      @condition = condition
      clear!
    end

    def clear!
      @queue = []
      @runs = 0
    end

    def to_proc
      proc do |*args|
        @mutex.synchronize do
          next if @condition&.call(*args)

          @queue << args
          @runs += 1
          @resource.signal
        end
      end
    end

    DEFAULT_TIMEOUT = 5

    def wait(runs: 1, timeout: DEFAULT_TIMEOUT, clear: false)
      @mutex.synchronize do
        (runs - @runs).times { @resource.wait(@mutex, timeout) }
      end
      result = @queue
      clear! if clear
      result
    end

    def runs(timeout: DEFAULT_TIMEOUT)
      @mutex.synchronize { @resource.wait(@mutex, timeout) }
      @runs
    end
  end
end
