xml.instruct!
xml.result do
  xml.status @output[:status]
  xml.total @output[:total]
  xml.url @output[:url] unless @output[:url].nil?
  xml.agent @output[:agent] unless @output[:agent].nil?
  xml.execution_time do
    xml.find_names_duration @output[:execution_time][:find_names_duration]
    xml.total_duration @output[:execution_time][:total_duration]
  end unless !@output[:execution_time]
  xml.engines do
    @output[:engines].each do |engine|
      xml.engine engine
    end
  end
  xml.names 'xmlns:dwc' => 'http://rs.tdwg.org/dwc/terms/' do
    @output[:names].each do |name|
      xml.name do
        xml.verbatim name[:verbatim]
        xml.dwc :scientificName, name[:scientificName]
        if name[:offsetStart] && name[:offsetEnd]
          xml.offsets do
            xml.offset 'start' => name[:offsetStart], 'end' => name[:offsetEnd]
          end
        end
      end
    end
  end
end