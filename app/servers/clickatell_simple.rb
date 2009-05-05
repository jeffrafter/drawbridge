require 'httparty'
 
class ClickatellSimple
  class UnknownError < StandardError; end
  class Error < StandardError
    def initialize(code, desc)
      @code = code.to_s
      @desc = desc
    end
 
    def to_s
      return "Error: #{@desc}. (#{@code})"
    end
 
    def code
      return @code
    end
 
    def description
      return @desc
    end
  end
  
  
  include HTTParty
  base_uri 'api.clickatell.com'
  
  attr_accessor :api_id, :user, :password
  
  def self.default
    @default ||= begin
      h = YAML.load_file(File.join(Rails.root, "config", "clickatell.yml"))
      ClickatellSimple.new(h["api_id"], h["user"], h["password"])
    end
  end
  
  def initialize(api_id, user, password)
    self.api_id = api_id
    self.user = user
    self.password = password
  end
  
  def sms(contents, destination, from)
    response = dispatch(:sendmsg, :to => destination, :text => contents, :from => from)
    check_error(response)
    if response.to_s =~ /^ID: (.*)$/
      return $1
    else
      raise UnknownError
    end
  end
  
  protected
  
  def authorization_parameters
    {
      :api_id => self.api_id,
      :user => self.user,
      :password => self.password
    }
  end
  
  def dispatch(command, params = {})
    api_path = File.join("/http", command.to_s)
    real_params = params.merge(authorization_parameters)
    self.class.get api_path, {:query => real_params}
  end
  
  def check_error(response)
    response.each_line do |line|
      if line =~ /^ERR: (.*)$/
        code, text = $1.split(",", 2)
        raise ClickatellSimple::Error.new(code.to_i, text)
      end
    end
  end
  
end