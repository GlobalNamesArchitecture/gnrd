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
  xml.data_sources do
    @output[:data_sources].each do |data_source|
      xml.data_source data_source[:title], :id => data_source[:id]
    end
  end if @output[:data_sources]
  xml.context do
    @output[:context].each do |context|
      xml.data_source context[:context_clade], :id => context[:context_data_source_id]
    end
  end if @output[:context]
  xml.resolved_names 'xmlns:dwc' => 'http://rs.tdwg.org/dwc/terms/' do
    @output[:resolved_names].each do |name|
      xml.name do
        xml.dwc :scientificName, name[:supplied_name_string]
        xml.results do
          name[:results].each do |r|
            xml.result r[:name_string], :canonical_form => r[:canonical_form], :data_source_id => r[:data_source_id], :taxon_id => r[:taxon_id], :gni_uuid => r[:gni_uuid], :score => r[:score], :match_type => r[:match_type]
          end if name[:results]
        end
      end
    end
  end if @output[:resolved_names]
end
