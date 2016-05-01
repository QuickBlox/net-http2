require 'spec_helper'

describe "SSL Requests" do
  let(:port) { 9516 }
  let(:server) { NetHttp2::Dummy::Server.new(port: port, ssl: true) }
  let(:client) { NetHttp2::Client.new("https://localhost:#{port}") }

  before { server.listen }
  after do
    client.close
    server.stop
  end

  it "sends SSL GET requests" do
    request       = nil
    server.on_req = Proc.new do |req|
      request = req

      NetHttp2::Response.new(
        headers: { ":status" => "200" },
        body:    "response body"
      )
    end

    response = client.call(:get, '/path')

    expect(response).to be_a NetHttp2::Response
    expect(response.body).to eq "response body"

    expect(request).not_to be_nil
    expect(request.headers[":scheme"]).to eq "https"
    expect(request.headers[":method"]).to eq "GET"
    expect(request.headers[":path"]).to eq "/path"
    expect(request.headers["host"]).to eq "localhost"
  end
end
