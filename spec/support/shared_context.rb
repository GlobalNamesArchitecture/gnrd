RSpec.shared_context "shared_context", a: :b do
  let(:d) { Gnrd::Dossier }
  let(:path) { File.absolute_path(__dir__ + "/../files") }

  let(:utf_path) { path + "/utf8.txt" }
  let(:utf_txt) { File.read(utf_path, encoding: "utf-8") }
  let(:utf_dossier) { d.new(file: { path: utf_path }) }
  let(:utf_txt_dossier) { d.new(text: { orig: utf_txt }) }

  let(:utf16_path) { path + "/utf16.txt" }
  let(:utf16_txt) { File.read(utf16_path, encoding: "utf-16") }
  let(:utf16_dossier) { d.new(file: { path: utf16_path }) }
  let(:utf16_txt_dossier) { d.new(text: { orig: utf16_txt }) }

  let(:ascii_path) { path + "/ascii.txt" }
  let(:ascii_txt) { File.read(ascii_path, encoding: "ascii") }
  let(:ascii_dossier) { d.new(file: { path: ascii_path }) }

  let(:latin1_path) { path + "/latin1.txt" }
  let(:latin1_txt) { File.read(latin1_path, encoding: "iso-8859-1") }
  let(:latin1_dossier) { d.new(file: { path: latin1_path }) }

  let(:html_path) { path + "/file.html" }
  let(:html_txt) { File.read(html_path, encoding: "utf-8") }
  let(:html_dossier) { d.new(file: { path: html_path }) }

  let(:xml_path) { path + "/file.xml" }
  let(:xml_txt) { File.read(xml_path, encoding: "utf-8") }
  let(:xml_dossier) { d.new(file: { path: xml_path }) }

  let(:img_path) { path + "/image.jpg" }
  let(:img_dossier) { d.new(file: { path: img_path }) }

  let(:img_no_names_path) { path + "/no_names.jpg" }
  let(:img_no_names_dossier) { d.new(file: { path: img_no_names_path }) }

  let(:pdf_path) { path + "/file.pdf" }
  let(:pdf_dossier) { d.new(file: { path: pdf_path }) }

  let(:pdf_img_path) { path + "/image.pdf" }
  let(:pdf_img_dossier) { d.new(file: { path: pdf_img_path }) }

  let(:binary_path) { path + "/binary" }
  let(:binary_dossier) { d.new(file: { path: binary_path }) }
end
