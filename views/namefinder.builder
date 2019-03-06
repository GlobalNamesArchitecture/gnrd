# frozen_string_literal: true

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
  if @output[:execution_time]
    xml.execution_time do
      xml.text_preparation_duration @output[:execution_time][:text_preparation_duration]
      xml.find_names_duration @output[:execution_time][:find_names_duration]
      if @output[:execution_time][:names_resolution_duration]
        xml.names_resolution_duration @output[:execution_time][:names_resolution_duration]
      end
      xml.total_duration @output[:execution_time][:total_duration]
    end
  end
  xml.engines do
    @output[:engines]&.each do |engine|
      xml.engine engine
    end
  end
  xml.content @output[:content] if @output[:content]
  xml.names "xmlns:dwc" => "http://rs.tdwg.org/dwc/terms/" do
    @output[:names]&.each do |name|
      xml.name do
        xml.verbatim name[:verbatim] if @output[:verbatim]
        xml.identifiedName name[:identifiedName] if name[:identifiedName]
        xml.dwc :scientificName, name[:scientificName]
        if name[:offsetStart] && name[:offsetEnd]
          xml.offset "start" => name[:offsetStart], "end" => name[:offsetEnd]
        end
      end
    end
  end
  xml.data_sources do
    @output[:data_sources]&.each do |data_source|
      xml.data_source do
        xml.data_source_id data_source[:id] if data_source[:id]
        xml.title data_source[:title] if data_source[:title]
      end
    end
  end
  xml.context do
    @output[:context]&.each do |context|
      if context[:context_data_source_id]
        xml.context_data_source_id context[:context_data_source_id]
      end
      xml.context_clade context[:context_clade] if context[:context_clade]
    end
  end
  xml.verified_names "xmlns:dwc" => "http://rs.tdwg.org/dwc/terms/" do
    @output[:verified_names]&.each do |name|
      xml.name do
        xml.dwc :scientificName, name[:supplied_name_string]
        xml.results do
          name[:results]&.each do |r|
            xml.result do
              xml.data_source_id r[:data_source_id] if r[:data_source_id]
              xml.gni_uuid r[:gni_uuid] if r[:gni_uuid]
              xml.name_string r[:name_string] if r[:name_string]
              xml.canonical_form r[:canonical_form] if r[:canonical_form]
              if r[:classification_path]
                xml.classification_path r[:classification_path]
              end
              if r[:classification_path_ids]
                xml.classification_path_ids r[:classification_path_ids]
              end
              xml.taxon_id r[:taxon_id] if r[:taxon_id]
              xml.current_taxon_id r[:current_taxon_id] if r[:current_taxon_id]
              if r[:current_name_string]
                xml.current_name_string r[:current_name_string]
              end
              xml.local_id r[:local_id] if r[:local_id]
              xml.global_id r[:global_id] if r[:global_id]
              xml.url r[:url] if r[:url]
              xml.match_type r[:match_type] if r[:match_type]
              xml.prescore r[:prescore] if r[:prescore]
              xml.score r[:score] if r[:score]
            end
          end
        end
      end
    end
  end
end
