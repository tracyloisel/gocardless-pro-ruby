require 'spec_helper'

describe GoCardlessPro::Resources::MandateImport do
  let(:client) do
    GoCardlessPro::Client.new(
      access_token: 'SECRET_TOKEN'
    )
  end

  let(:response_headers) { { 'Content-Type' => 'application/json' } }

  describe '#create' do
    subject(:post_create_response) { client.mandate_imports.create(params: new_resource) }
    context 'with a valid request' do
      let(:new_resource) do
        {

          'created_at' => 'created_at-input',
          'id' => 'id-input',
          'scheme' => 'scheme-input',
          'status' => 'status-input',
        }
      end

      before do
        stub_request(:post, %r{.*api.gocardless.com/mandate_imports}).
          with(
            body: {
              'mandate_imports' => {

                'created_at' => 'created_at-input',
                'id' => 'id-input',
                'scheme' => 'scheme-input',
                'status' => 'status-input',
              },
            }
          ).
          to_return(
            body: {
              'mandate_imports' =>

                {

                  'created_at' => 'created_at-input',
                  'id' => 'id-input',
                  'scheme' => 'scheme-input',
                  'status' => 'status-input',
                },

            }.to_json,
            headers: response_headers
          )
      end

      it 'creates and returns the resource' do
        expect(post_create_response).to be_a(GoCardlessPro::Resources::MandateImport)
      end
    end

    context 'with a request that returns a validation error' do
      let(:new_resource) { {} }

      before do
        stub_request(:post, %r{.*api.gocardless.com/mandate_imports}).to_return(
          body: {
            error: {
              type: 'validation_failed',
              code: 422,
              errors: [
                { message: 'test error message', field: 'test_field' },
              ],
            },
          }.to_json,
          headers: response_headers,
          status: 422
        )
      end

      it 'throws the correct error' do
        expect { post_create_response }.to raise_error(GoCardlessPro::ValidationError)
      end
    end

    context 'with a request that returns an idempotent creation conflict error' do
      let(:id) { 'ID123' }

      let(:new_resource) do
        {

          'created_at' => 'created_at-input',
          'id' => 'id-input',
          'scheme' => 'scheme-input',
          'status' => 'status-input',
        }
      end

      let!(:post_stub) do
        stub_request(:post, %r{.*api.gocardless.com/mandate_imports}).to_return(
          body: {
            error: {
              type: 'invalid_state',
              code: 409,
              errors: [
                {
                  message: 'A resource has already been created with this idempotency key',
                  reason: 'idempotent_creation_conflict',
                  links: {
                    conflicting_resource_id: id,
                  },
                },
              ],
            },
          }.to_json,
          headers: response_headers,
          status: 409
        )
      end

      let!(:get_stub) do
        stub_url = "/mandate_imports/#{id}"
        stub_request(:get, /.*api.gocardless.com#{stub_url}/).
          to_return(
            body: {
              'mandate_imports' => {

                'created_at' => 'created_at-input',
                'id' => 'id-input',
                'scheme' => 'scheme-input',
                'status' => 'status-input',
              },
            }.to_json,
            headers: response_headers
          )
      end

      it 'fetches the already-created resource' do
        post_create_response
        expect(post_stub).to have_been_requested
        expect(get_stub).to have_been_requested
      end
    end
  end

  describe '#get' do
    let(:id) { 'ID123' }

    subject(:get_response) { client.mandate_imports.get(id) }

    context 'passing in a custom header' do
      let!(:stub) do
        stub_url = '/mandate_imports/:identity'.gsub(':identity', id)
        stub_request(:get, /.*api.gocardless.com#{stub_url}/).
          with(headers: { 'Foo' => 'Bar' }).
          to_return(
            body: {
              'mandate_imports' => {

                'created_at' => 'created_at-input',
                'id' => 'id-input',
                'scheme' => 'scheme-input',
                'status' => 'status-input',
              },
            }.to_json,
            headers: response_headers
          )
      end

      subject(:get_response) do
        client.mandate_imports.get(id, headers: {
                                     'Foo' => 'Bar',
                                   })
      end

      it 'includes the header' do
        get_response
        expect(stub).to have_been_requested
      end
    end

    context 'when there is a mandate_import to return' do
      before do
        stub_url = '/mandate_imports/:identity'.gsub(':identity', id)
        stub_request(:get, /.*api.gocardless.com#{stub_url}/).to_return(
          body: {
            'mandate_imports' => {

              'created_at' => 'created_at-input',
              'id' => 'id-input',
              'scheme' => 'scheme-input',
              'status' => 'status-input',
            },
          }.to_json,
          headers: response_headers
        )
      end

      it 'wraps the response in a resource' do
        expect(get_response).to be_a(GoCardlessPro::Resources::MandateImport)
      end
    end

    context 'when nothing is returned' do
      before do
        stub_url = '/mandate_imports/:identity'.gsub(':identity', id)
        stub_request(:get, /.*api.gocardless.com#{stub_url}/).to_return(
          body: '',
          headers: response_headers
        )
      end

      it 'returns nil' do
        expect(get_response).to be_nil
      end
    end

    context "when an ID is specified which can't be included in a valid URI" do
      let(:id) { '`' }

      it "doesn't raise an error" do
        expect { get_response }.to_not raise_error(/bad URI/)
      end
    end
  end

  describe '#submit' do
    subject(:post_response) { client.mandate_imports.submit(resource_id) }

    let(:resource_id) { 'ABC123' }

    let!(:stub) do
      # /mandate_imports/%v/actions/submit
      stub_url = '/mandate_imports/:identity/actions/submit'.gsub(':identity', resource_id)
      stub_request(:post, /.*api.gocardless.com#{stub_url}/).to_return(

        body: {
          'mandate_imports' => {

            'created_at' => 'created_at-input',
            'id' => 'id-input',
            'scheme' => 'scheme-input',
            'status' => 'status-input',
          },
        }.to_json,

        headers: response_headers
      )
    end

    it 'wraps the response and calls the right endpoint' do
      expect(post_response).to be_a(GoCardlessPro::Resources::MandateImport)

      expect(stub).to have_been_requested
    end

    context 'when the request needs a body and custom header' do
      let(:body) { { foo: 'bar' } }
      let(:headers) { { 'Foo' => 'Bar' } }
      subject(:post_response) { client.mandate_imports.submit(resource_id, body, headers) }

      let(:resource_id) { 'ABC123' }

      let!(:stub) do
        # /mandate_imports/%v/actions/submit
        stub_url = '/mandate_imports/:identity/actions/submit'.gsub(':identity', resource_id)
        stub_request(:post, /.*api.gocardless.com#{stub_url}/).
          with(
            body: { foo: 'bar' },
            headers: { 'Foo' => 'Bar' }
          ).to_return(
            body: {
              'mandate_imports' => {

                'created_at' => 'created_at-input',
                'id' => 'id-input',
                'scheme' => 'scheme-input',
                'status' => 'status-input',
              },
            }.to_json,
            headers: response_headers
          )
      end
    end
  end

  describe '#cancel' do
    subject(:post_response) { client.mandate_imports.cancel(resource_id) }

    let(:resource_id) { 'ABC123' }

    let!(:stub) do
      # /mandate_imports/%v/actions/cancel
      stub_url = '/mandate_imports/:identity/actions/cancel'.gsub(':identity', resource_id)
      stub_request(:post, /.*api.gocardless.com#{stub_url}/).to_return(

        body: {
          'mandate_imports' => {

            'created_at' => 'created_at-input',
            'id' => 'id-input',
            'scheme' => 'scheme-input',
            'status' => 'status-input',
          },
        }.to_json,

        headers: response_headers
      )
    end

    it 'wraps the response and calls the right endpoint' do
      expect(post_response).to be_a(GoCardlessPro::Resources::MandateImport)

      expect(stub).to have_been_requested
    end

    context 'when the request needs a body and custom header' do
      let(:body) { { foo: 'bar' } }
      let(:headers) { { 'Foo' => 'Bar' } }
      subject(:post_response) { client.mandate_imports.cancel(resource_id, body, headers) }

      let(:resource_id) { 'ABC123' }

      let!(:stub) do
        # /mandate_imports/%v/actions/cancel
        stub_url = '/mandate_imports/:identity/actions/cancel'.gsub(':identity', resource_id)
        stub_request(:post, /.*api.gocardless.com#{stub_url}/).
          with(
            body: { foo: 'bar' },
            headers: { 'Foo' => 'Bar' }
          ).to_return(
            body: {
              'mandate_imports' => {

                'created_at' => 'created_at-input',
                'id' => 'id-input',
                'scheme' => 'scheme-input',
                'status' => 'status-input',
              },
            }.to_json,
            headers: response_headers
          )
      end
    end
  end
end
