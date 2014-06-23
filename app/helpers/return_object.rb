class ReturnObject
  attr_accessor :status, :info, :object

  def initialize(status, info, obj)
    @status = status
    @info = info
    @object = obj
  end
end
