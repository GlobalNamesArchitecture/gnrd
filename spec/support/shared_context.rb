RSpec.shared_context "shared_context", a: :b do
  let(:d) { Gnrd::Dossier }
  let(:path) { File.absolute_path(__dir__ + "/../files") }
  let(:utf_path) { path + "/french.txt" }
  let(:utf_txt) { File.read(utf_path) }
  let(:utf_dossier) { d.new(file: { path: utf_path }) }
  let(:utf_txt_dossier) { d.new(text: { orig: utf_txt }) }
end
