require 'docx_report/data_item'

module DocxReport
  class Record
    include DataItem

    def initialize
      @fields = []
      @tables = []
    end
  end
end
