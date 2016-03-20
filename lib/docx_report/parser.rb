require 'nokogiri'

module DocxReport
  class Parser
    def initialize(document)
      @document = document
    end

    def replace_all_fields(fields)
      @document.files.each do |file|
        replace_node_fields(fields, file.xml)
        replace_node_hyperlinks(fields, file.xml, file)
      end
    end

    def fill_all_tables(tables)
      @document.files.each do |file|
        fill_tables(tables, file.xml, file)
      end
    end

    private

    def find_text_nodes(name, parent_node)
      parent_node.xpath(".//*[contains(text(), '#{name}')]")
    end

    def find_hyperlink_nodes(name, parent_node, file)
      links = file.rels_xml.xpath "//*[@Target='#{name}']"
      parent_node.xpath(".//w:hyperlink[@r:id='#{find_by_Id(links)}']")
    end

    def find_by_Id(links)
      links.map { |link| link[:Id] }.join("' or @r:id='")
    end

    def replace_node_fields(fields, parent_node)
      fields.select { |f| f.type == :text }.each do |field|
        find_text_nodes(field.name, parent_node).map do |node|
          node.content = node.content.gsub field.name, field.value
        end
      end
    end

    def replace_node_hyperlinks(fields, parent_node, file, create = false)
      fields.select { |f| f.type == :hyperlink }.each do |field|
        find_hyperlink_nodes(field.name, parent_node, file).each do |node|
          hyperlink = Hyperlink.new(field.value, file,
                                    (node['r:id'] unless create))
          node['r:id'] = hyperlink.id
        end
      end
    end

    def find_table(name, parent_node)
      parent_node.xpath(".//w:tbl[//w:tblCaption[@w:val='#{name}']][1]")
                    .first
    end

    def find_row(table, table_node)
      row_number = table.has_header ? 2 : 1
      table_node.xpath(".//w:tr[#{row_number}]").first
    end

    def fill_tables(tables, parent_node, file)
      tables.each do |table|
        tbl = find_table table.name, parent_node
        next if tbl.nil?
        tbl_row = find_row table, tbl
        fill_table_rows(table, tbl_row, file) unless tbl_row.nil?
      end
    end

    def fill_table_rows(table, row_node, file)
      table.records.each do |record|
        new_row = row_node.dup
        row_node.add_previous_sibling new_row
        replace_node_fields record.fields, new_row
        replace_node_hyperlinks record.fields, new_row, file, true
      end
      row_node.remove
    end
  end
end
