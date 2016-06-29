module DocxReport
  module DataItem
    attr_reader :fields, :images, :tables

    def add_field(name, value, type = :text, text_direction = :none)
      field = Field.new name, value, type, text_direction
      raise 'duplicate field name' if @fields.any? { |f| f.name == field.name }
      @fields << field
    end
  end
end
