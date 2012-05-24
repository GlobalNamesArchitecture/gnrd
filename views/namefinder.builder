xml.instruct!
xml.result do
  xml.status @output[:status]
  xml.message @output[:message] if @output[:message]
  xml.total @output[:total] if @output[:total]
  xml.input_url @output[:input_url] if @output[:input_url]
  xml.url @output[:url] if @output[:url]
  xml.agent @output[:agent] if @output[:agent]
  xml.execution_time do
    xml.find_names_duration @output[:execution_time][:find_names_duration]
    xml.total_duration @output[:execution_time][:total_duration]
  end unless !@output[:execution_time]
  xml.engines do
    @output[:engines].each do |engine|
      xml.engine engine
    end
  end if @output[:engines]
  xml.names 'xmlns:dwc' => 'http://rs.tdwg.org/dwc/terms/' do
    @output[:names].each do |name|
      xml.name do
        xml.verbatim name[:verbatim]
        xml.dwc :scientificName, name[:scientificName]
        if name[:offsetStart] && name[:offsetEnd]
          xml.offset 'start' => name[:offsetStart], 'end' => name[:offsetEnd]
        end
      end
    end
  end if @output[:names]
end
