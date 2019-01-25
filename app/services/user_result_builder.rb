class MicropostResultBuilder < ResultBuilderBase
  def build_result
    "#{@record.name}, #{@record.email}"
  end
end