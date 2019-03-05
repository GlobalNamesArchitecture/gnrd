# frozen_string_literal: true

# ApplicationHelpers module contains helpers for GNRD
module ApplicationHelpers
  CONTENT_TYPE = { html: "text/html",
                   json: "application/json",
                   xml: "application/xml" }.freeze

  def name_finder_init
    return find_by_token if params[:token]

    create_name_finder
  end

  def find_names
    init_find if @nf.state == :idle
    @nf.state == :finished ? show_find : show_process
  end

  private

  def init_find
    with_resque? ? NameFinder.enqueue(@nf) : NameFinderWorker.find_names(@nf)
  end

  def show_find
    if @nf.errs.empty?
      show_process
    else
      show_errors(@nf.errs)
    end
  end

  def show_process
    status_code = format == :html || params[:token] ? 200 : 303
    present(status_code, @nf.output)
  end

  def with_resque?
    !Resque.redis.smembers("workers").empty? && Gnrd.env != :test
  end

  def create_name_finder
    nf = NameFinder.create(params: HashSerializer.symbolize_keys(params))
    err = nf.valid? ? [] : nf.errors[:base]
    [nf, err]
  end

  def find_by_token
    err = []
    nf = NameFinder.find_by_token(params[:token])
    if nf
      nf.params_update(params)
      err += nf.errs unless nf.errs.empty?
    else
      err << { status: 404, parameters: { token: params[:token] },
               message: "Not Found. That result no longer exists." }
    end
    [nf, err]
  end

  def format
    @format ||= Params.new(params).format
  end

  def show_errors(err)
    e = err.first
    if format == :html
      redirect "/", error: e[:message]
    else
      present(e[:status], e)
    end
  end

  def present(status_code, output)
    status status_code
    content_type CONTENT_TYPE[format]
    @output = adjust_output(output)
    @redirect_url = @output[:status] == 303 ? @output[:token_url] : nil
    format == :html ? haml(:name_finder) : present_or_redirect
  end

  def present_or_redirect
    if request.url != @output[:token_url] && status.between?(300, 399)
      redirect(@output[:token_url], status)
    end
    case format
    when :xml  then builder :namefinder
    when :json then JSON.dump @output
    end
  end

  def adjust_output(output)
    if output[:token_url]
      output[:token_url] = request.base_url + output[:token_url]
    end
    output[:queue_size] = Resque.size(:NameFinder) if with_resque?
    output
  end
end
