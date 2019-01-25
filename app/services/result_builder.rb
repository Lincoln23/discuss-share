class ResultBuilder
  attr_accessor :record
  def initialize(record)
    @record = record
  end

  def self.call(record)
    new(record).call
  end

  def call
    class_name.build_result
  end

  private

  def class_name
    "#{@record.class.name}ResultBuilder".constantize.new(@record)
  end
end