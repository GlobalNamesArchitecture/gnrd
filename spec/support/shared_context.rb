RSpec.shared_context "shared_context", a: :b do
  let(:d) { Gnrd::Dossier }
  let(:path) { File.absolute_path(__dir__ + "/../files") }

  let(:utf_path) { path + "/french.txt" }
  let(:utf_txt) { File.read(utf_path) }
  let(:utf_dossier) { d.new(file: { path: utf_path }) }
  let(:utf_txt_dossier) { d.new(text: { orig: utf_txt }) }

  let(:ascii_path) { path + "/ascii.txt" }
  let(:ascii_txt) { File.read(ascii_path) }
  let(:ascii_dossier) { d.new(file: { path: ascii_path }) }

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
