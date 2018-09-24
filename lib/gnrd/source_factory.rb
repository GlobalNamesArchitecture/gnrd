# frozen_string_literal: true

module Gnrd
  # Creates an instance of a source which corresponds to given information
  module SourceFactory
    def self.inst(dossier)
      path = dossier.file[:path]
      dossier.file(FileInspector.info(path)) unless dossier.file[:type]
      type = dossier.file[:type].split("_").map(&:capitalize).join("")
      const_get("Gnrd::#{type}").new(dossier)
    end
  end
end
