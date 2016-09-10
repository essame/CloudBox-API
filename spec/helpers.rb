module Helpers
  def parsed_response
    JSON.parse(last_response.body)
  end

  def parsed_response_symbolize
    JSON.parse(last_response.body).deep_symbolize_keys
  end
end