class Errors
  def initialize(name_finder)
    @nf = name_finder
    @errors = []
  end

  def validate
    check_source_exist
    @errors
  end

  private

  def check_source_exist
    if @nf.params[:source].empty?
      @errors << { status_code: 400,
                   message: "Bad Request. Parameters missing." }
    end
  end
end
