xml.instruct!
xml.result do
  xml.status @output[:status]
  xml.queue_size @output[:queue_size] if @output[:queue_size]
  xml.token_url @output[:token_url] if @output[:token_url]
  xml.message @output[:message] if @output[:message]
  xml.total @output[:total] if @output[:total]
  xml.input_url @output[:input_url] if @output[:input_url]
  xml.file @output[:file] if @output[:file]
  xml.agent @output[:agent] if @output[:agent]
  xml.english @output[:english] if @output[:english]
  xml.execution_time do
    xml.find_names_duration @output[:execution_time][:find_names_duration]
    xml.resolve_names_duration @output[:execution_time][:resolve_names_duration] if @output[:execution_time][:resolve_names_duration]
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
        xml.verbatim name[:verbatim] if @output[:verbatim]
        xml.identifiedName name[:identifiedName] if name[:identifiedName]
        xml.dwc :scientificName, name[:scientificName]
        if name[:offsetStart] && name[:offsetEnd]
          xml.offset 'start' => name[:offsetStart], 'end' => name[:offsetEnd]
        end
      end
    end
  end if @output[:names]
end
