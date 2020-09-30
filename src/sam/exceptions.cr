Exception::CallStack.skip(__FILE__)

module Sam
  class NotFound < Exception
    def initialize(task)
      @message = "Task #{task} was not found"
    end
  end
end
