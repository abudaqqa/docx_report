
require 'docx_report/block_value'

module DocxReport
  class Field
    include BlockValue
    attr_reader :name, :value, :type, :text_direction

    def initialize(name, value = nil, type = :text, text_direction = :none,
                   &block)
      @name = "@#{name}@"
      @type = type
      @text_direction = text_direction
      set_value(value || block)
    end

    def set_value(value = nil, &block)
      @value = value || block
    end

    def load_field(item)
      Field.new(name[1..-2], load_value(item), type, load_text_direction(item))
    end
  end
end
