class Background
  def self.process(&block)
    Thread.new do
      yield
      ActiveRecord::Base.connection.close
    end
  end
end