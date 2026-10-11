require 'rails_helper'

RSpec.describe JinaService do
  let(:url) { 'https://example.com/my-recipe' }
  let(:http) { instance_double(Net::HTTP) }

  before do
    allow(Net::HTTP).to receive(:new).and_return(http)
    allow(http).to receive(:use_ssl=)
    allow(http).to receive(:open_timeout=)
    allow(http).to receive(:read_timeout=)
  end

  describe '#fetch_markdown' do
    it 'returns the body on success' do
      allow(http).to receive(:request).and_return(Net::HTTPOK.new('1.1', '200', 'OK').tap { |r| allow(r).to receive(:body).and_return('# Recipe') })

      expect(described_class.new.fetch_markdown(url)).to eq('# Recipe')
    end

    [451, 429, 500].each do |status|
      it "raises JinaService::Error carrying the status for HTTP #{status}" do
        response = Net::HTTPResponse::CODE_TO_OBJ[status.to_s].new('1.1', status.to_s, 'err')
        allow(response).to receive(:body).and_return('')
        allow(http).to receive(:request).and_return(response)

        expect { described_class.new.fetch_markdown(url) }
          .to raise_error(JinaService::Error) { |e| expect(e.status).to eq(status) }
      end
    end
  end
end
