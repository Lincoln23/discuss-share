class MicropostResultBuilder < ResultBuilderBase
  def build_result
    "#{@record.user_id}, #{@record.content}"
  end
end