# frozen_string_literal: true

# Validates create and update input for NameFinder
class NameFinderValidator < ActiveModel::Validator
  def validate(nf)
    @nf = nf
    source_exist?
  end

  private

  def source_exist?
    return unless @nf.params[:source].nil? || @nf.params[:source].empty?

    @nf.errors[:base] << { status: 400,
                           message: "Bad request. Parameters missing.",
                           parameters: Params.output(@nf.params) }
  end
end
