require 'nokogiri'
require 'crxmake'

module Namespotter
  
  module Chrome
    def build_chrome_extension(version, fqd = 'http://gnrd.globalnames.org/')
      @version = version
      @fqd = fqd
      construct_crx
      construct_updates
    end
    
    private
    
    def construct_updates
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.gupdate(:xmlns => 'http://www.google.com/update2/response', :protocol => '2.0') do
          xml.app(:appid => Namespotter::Application.config.chrome_app_id) do
            xml.updatecheck(:codebase => @fqd + ['namespotter','namespotter.crx'].join("/"), :version => @version)
          end
        end
      end
      xml_data = builder.to_xml
      updates_file = open(File.join(Rails.root, "public", "namespotter", 'updates.xml'), 'w:utf-8')
      updates_file.write(xml_data)
      updates_file.close
    end
    
    def construct_crx
      CrxMake.make(
        :ex_dir => Rails.root.join("app", "namespotter", "src").to_s,
        :pkey   => Rails.root.join("app", "namespotter","namespotter.pem").to_s,
        :crx_output => Rails.root.join("public", "namespotter","namespotter.crx").to_s,
        :verbose => true
      )
    end
  end
end