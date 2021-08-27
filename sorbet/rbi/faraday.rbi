# This RBI is here for patching generated method from Faraday.
# From: https://github.com/sorbet/sorbet-typed/tree/master/lib/faraday/all
# typed: true
module Faraday
  sig do
    params(
        url: String,
        body: T.any(String, T.nilable(T::Hash[Object, Object])),
        headers: T.nilable(T::Hash[Object, String]),
        block: T.nilable(T.proc.params(req: Request).void),
      )
      .returns(Response)
  end
  def self.post(url, body = nil, headers = nil, &block); end

  class Request
    def headers; end
    def headers=(hash); end
  end
end
