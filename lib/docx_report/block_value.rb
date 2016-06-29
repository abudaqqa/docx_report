module DocxReport
  module BlockValue
    def load_value(item)
      if @value.is_a? Proc
        val = @value.call(item)
        val.is_a?(Hash) ? val[:value] : val
      else
        item.is_a?(Hash) ? item[@value] : item.send(@value)
      end
    end

    def load_text_direction(item)
      if @value.is_a? Proc
        val = @value.call(item)
        val.is_a?(Hash) ? val[:text_direction] : :none
      else
        :none
      end
    end
  end
end
