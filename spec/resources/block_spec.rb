require 'spec_helper'

describe GoCardlessPro::Resources::Block do
  let(:client) do
    GoCardlessPro::Client.new(
      access_token: 'SECRET_TOKEN'
    )
  end

  let(:response_headers) { { 'Content-Type' => 'application/json' } }

  describe '#create' do
    subject(:post_create_response) { client.blocks.create(params: new_resource) }
    context 'with a valid request' do
      let(:new_resource) do
        {

          'active' => 'active-input',
          'block_type' => 'block_type-input',
          'created_at' => 'created_at-input',
          'id' => 'id-input',
          'reason_description' => 'reason_description-input',
          'reason_type' => 'reason_type-input',
          'resource_reference' => 'resource_reference-input',
          'updated_at' => 'updated_at-input',
        }
      end

      before do
        stub_request(:post, %r{.*api.gocardless.com/blocks}).
          with(
            body: {
              'blocks' => {

                'active' => 'active-input',
                'block_type' => 'block_type-input',
                'created_at' => 'created_at-input',
                'id' => 'id-input',
                'reason_description' => 'reason_description-input',
                'reason_type' => 'reason_type-input',
                'resource_reference' => 'resource_reference-input',
                'updated_at' => 'updated_at-input',
              },
            }
          ).
          to_return(
            body: {
              'blocks' =>

                {

                  'active' => 'active-input',
                  'block_type' => 'block_type-input',
                  'created_at' => 'created_at-input',
                  'id' => 'id-input',
                  'reason_description' => 'reason_description-input',
                  'reason_type' => 'reason_type-input',
                  'resource_reference' => 'resource_reference-input',
                  'updated_at' => 'updated_at-input',
                },

            }.to_json,
            headers: response_headers
          )
      end

      it 'creates and returns the resource' do
        expect(post_create_response).to be_a(GoCardlessPro::Resources::Block)
      end
    end

    context 'with a request that returns a validation error' do
      let(:new_resource) { {} }

      before do
        stub_request(:post, %r{.*api.gocardless.com/blocks}).to_return(
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

          'active' => 'active-input',
          'block_type' => 'block_type-input',
          'created_at' => 'created_at-input',
          'id' => 'id-input',
          'reason_description' => 'reason_description-input',
          'reason_type' => 'reason_type-input',
          'resource_reference' => 'resource_reference-input',
          'updated_at' => 'updated_at-input',
        }
      end

      let!(:post_stub) do
        stub_request(:post, %r{.*api.gocardless.com/blocks}).to_return(
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
        stub_url = "/blocks/#{id}"
        stub_request(:get, /.*api.gocardless.com#{stub_url}/).
          to_return(
            body: {
              'blocks' => {

                'active' => 'active-input',
                'block_type' => 'block_type-input',
                'created_at' => 'created_at-input',
                'id' => 'id-input',
                'reason_description' => 'reason_description-input',
                'reason_type' => 'reason_type-input',
                'resource_reference' => 'resource_reference-input',
                'updated_at' => 'updated_at-input',
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

    subject(:get_response) { client.blocks.get(id) }

    context 'passing in a custom header' do
      let!(:stub) do
        stub_url = '/blocks/:identity'.gsub(':identity', id)
        stub_request(:get, /.*api.gocardless.com#{stub_url}/).
          with(headers: { 'Foo' => 'Bar' }).
          to_return(
            body: {
              'blocks' => {

                'active' => 'active-input',
                'block_type' => 'block_type-input',
                'created_at' => 'created_at-input',
                'id' => 'id-input',
                'reason_description' => 'reason_description-input',
                'reason_type' => 'reason_type-input',
                'resource_reference' => 'resource_reference-input',
                'updated_at' => 'updated_at-input',
              },
            }.to_json,
            headers: response_headers
          )
      end

      subject(:get_response) do
        client.blocks.get(id, headers: {
                            'Foo' => 'Bar',
                          })
      end

      it 'includes the header' do
        get_response
        expect(stub).to have_been_requested
      end
    end

    context 'when there is a block to return' do
      before do
        stub_url = '/blocks/:identity'.gsub(':identity', id)
        stub_request(:get, /.*api.gocardless.com#{stub_url}/).to_return(
          body: {
            'blocks' => {

              'active' => 'active-input',
              'block_type' => 'block_type-input',
              'created_at' => 'created_at-input',
              'id' => 'id-input',
              'reason_description' => 'reason_description-input',
              'reason_type' => 'reason_type-input',
              'resource_reference' => 'resource_reference-input',
              'updated_at' => 'updated_at-input',
            },
          }.to_json,
          headers: response_headers
        )
      end

      it 'wraps the response in a resource' do
        expect(get_response).to be_a(GoCardlessPro::Resources::Block)
      end
    end

    context 'when nothing is returned' do
      before do
        stub_url = '/blocks/:identity'.gsub(':identity', id)
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

  describe '#list' do
    describe 'with no filters' do
      subject(:get_list_response) { client.blocks.list }

      before do
        stub_request(:get, %r{.*api.gocardless.com/blocks}).to_return(
          body: {
            'blocks' => [{

              'active' => 'active-input',
              'block_type' => 'block_type-input',
              'created_at' => 'created_at-input',
              'id' => 'id-input',
              'reason_description' => 'reason_description-input',
              'reason_type' => 'reason_type-input',
              'resource_reference' => 'resource_reference-input',
              'updated_at' => 'updated_at-input',
            }],
            meta: {
              cursors: {
                before: nil,
                after: 'ABC123',
              },
            },
          }.to_json,
          headers: response_headers
        )
      end

      it 'wraps each item in the resource class' do
        expect(get_list_response.records.map(&:class).uniq.first).to eq(GoCardlessPro::Resources::Block)

        expect(get_list_response.records.first.active).to eq('active-input')

        expect(get_list_response.records.first.block_type).to eq('block_type-input')

        expect(get_list_response.records.first.created_at).to eq('created_at-input')

        expect(get_list_response.records.first.id).to eq('id-input')

        expect(get_list_response.records.first.reason_description).to eq('reason_description-input')

        expect(get_list_response.records.first.reason_type).to eq('reason_type-input')

        expect(get_list_response.records.first.resource_reference).to eq('resource_reference-input')

        expect(get_list_response.records.first.updated_at).to eq('updated_at-input')
      end

      it 'exposes the cursors for before and after' do
        expect(get_list_response.before).to eq(nil)
        expect(get_list_response.after).to eq('ABC123')
      end

      specify { expect(get_list_response.api_response.headers).to eql('content-type' => 'application/json') }
    end
  end

  describe '#all' do
    let!(:first_response_stub) do
      stub_request(:get, %r{.*api.gocardless.com/blocks$}).to_return(
        body: {
          'blocks' => [{

            'active' => 'active-input',
            'block_type' => 'block_type-input',
            'created_at' => 'created_at-input',
            'id' => 'id-input',
            'reason_description' => 'reason_description-input',
            'reason_type' => 'reason_type-input',
            'resource_reference' => 'resource_reference-input',
            'updated_at' => 'updated_at-input',
          }],
          meta: {
            cursors: { after: 'AB345' },
            limit: 1,
          },
        }.to_json,
        headers: response_headers
      )
    end

    let!(:second_response_stub) do
      stub_request(:get, %r{.*api.gocardless.com/blocks\?after=AB345}).to_return(
        body: {
          'blocks' => [{

            'active' => 'active-input',
            'block_type' => 'block_type-input',
            'created_at' => 'created_at-input',
            'id' => 'id-input',
            'reason_description' => 'reason_description-input',
            'reason_type' => 'reason_type-input',
            'resource_reference' => 'resource_reference-input',
            'updated_at' => 'updated_at-input',
          }],
          meta: {
            limit: 2,
            cursors: {},
          },
        }.to_json,
        headers: response_headers
      )
    end

    it 'automatically makes the extra requests' do
      expect(client.blocks.all.to_a.length).to eq(2)
      expect(first_response_stub).to have_been_requested
      expect(second_response_stub).to have_been_requested
    end
  end

  describe '#disable' do
    subject(:post_response) { client.blocks.disable(resource_id) }

    let(:resource_id) { 'ABC123' }

    let!(:stub) do
      # /blocks/%v/actions/disable
      stub_url = '/blocks/:identity/actions/disable'.gsub(':identity', resource_id)
      stub_request(:post, /.*api.gocardless.com#{stub_url}/).to_return(

        body: {
          'blocks' => {

            'active' => 'active-input',
            'block_type' => 'block_type-input',
            'created_at' => 'created_at-input',
            'id' => 'id-input',
            'reason_description' => 'reason_description-input',
            'reason_type' => 'reason_type-input',
            'resource_reference' => 'resource_reference-input',
            'updated_at' => 'updated_at-input',
          },
        }.to_json,

        headers: response_headers
      )
    end

    it 'wraps the response and calls the right endpoint' do
      expect(post_response).to be_a(GoCardlessPro::Resources::Block)

      expect(stub).to have_been_requested
    end

    context 'when the request needs a body and custom header' do
      let(:body) { { foo: 'bar' } }
      let(:headers) { { 'Foo' => 'Bar' } }
      subject(:post_response) { client.blocks.disable(resource_id, body, headers) }

      let(:resource_id) { 'ABC123' }

      let!(:stub) do
        # /blocks/%v/actions/disable
        stub_url = '/blocks/:identity/actions/disable'.gsub(':identity', resource_id)
        stub_request(:post, /.*api.gocardless.com#{stub_url}/).
          with(
            body: { foo: 'bar' },
            headers: { 'Foo' => 'Bar' }
          ).to_return(
            body: {
              'blocks' => {

                'active' => 'active-input',
                'block_type' => 'block_type-input',
                'created_at' => 'created_at-input',
                'id' => 'id-input',
                'reason_description' => 'reason_description-input',
                'reason_type' => 'reason_type-input',
                'resource_reference' => 'resource_reference-input',
                'updated_at' => 'updated_at-input',
              },
            }.to_json,
            headers: response_headers
          )
      end
    end
  end

  describe '#enable' do
    subject(:post_response) { client.blocks.enable(resource_id) }

    let(:resource_id) { 'ABC123' }

    let!(:stub) do
      # /blocks/%v/actions/enable
      stub_url = '/blocks/:identity/actions/enable'.gsub(':identity', resource_id)
      stub_request(:post, /.*api.gocardless.com#{stub_url}/).to_return(

        body: {
          'blocks' => {

            'active' => 'active-input',
            'block_type' => 'block_type-input',
            'created_at' => 'created_at-input',
            'id' => 'id-input',
            'reason_description' => 'reason_description-input',
            'reason_type' => 'reason_type-input',
            'resource_reference' => 'resource_reference-input',
            'updated_at' => 'updated_at-input',
          },
        }.to_json,

        headers: response_headers
      )
    end

    it 'wraps the response and calls the right endpoint' do
      expect(post_response).to be_a(GoCardlessPro::Resources::Block)

      expect(stub).to have_been_requested
    end

    context 'when the request needs a body and custom header' do
      let(:body) { { foo: 'bar' } }
      let(:headers) { { 'Foo' => 'Bar' } }
      subject(:post_response) { client.blocks.enable(resource_id, body, headers) }

      let(:resource_id) { 'ABC123' }

      let!(:stub) do
        # /blocks/%v/actions/enable
        stub_url = '/blocks/:identity/actions/enable'.gsub(':identity', resource_id)
        stub_request(:post, /.*api.gocardless.com#{stub_url}/).
          with(
            body: { foo: 'bar' },
            headers: { 'Foo' => 'Bar' }
          ).to_return(
            body: {
              'blocks' => {

                'active' => 'active-input',
                'block_type' => 'block_type-input',
                'created_at' => 'created_at-input',
                'id' => 'id-input',
                'reason_description' => 'reason_description-input',
                'reason_type' => 'reason_type-input',
                'resource_reference' => 'resource_reference-input',
                'updated_at' => 'updated_at-input',
              },
            }.to_json,
            headers: response_headers
          )
      end
    end
  end

  describe '#block_by_ref' do
    subject(:post_response) { client.blocks.block_by_ref }

    let(:resource_id) { 'ABC123' }

    let!(:stub) do
      # /block_by_ref
      stub_url = '/block_by_ref'.gsub(':identity', resource_id)
      stub_request(:post, /.*api.gocardless.com#{stub_url}/).to_return(

        body: {
          'blocks' => [{

            'active' => 'active-input',
            'block_type' => 'block_type-input',
            'created_at' => 'created_at-input',
            'id' => 'id-input',
            'reason_description' => 'reason_description-input',
            'reason_type' => 'reason_type-input',
            'resource_reference' => 'resource_reference-input',
            'updated_at' => 'updated_at-input',
          }],
          meta: {
            cursors: {
              before: nil,
              after: 'ABC123',
            },
          },
        }.to_json,

        headers: response_headers
      )
    end

    it 'wraps the response and calls the right endpoint' do
      expect(post_response.records.map(&:class).uniq.first).to eq(GoCardlessPro::Resources::Block)

      expect(stub).to have_been_requested
    end

    it 'exposes the cursors for before and after' do
      expect(post_response.before).to eq(nil)
      expect(post_response.after).to eq('ABC123')
    end

    context 'when the request needs a body and custom header' do
      subject(:post_response) { client.blocks.block_by_ref(body, headers) }

      let(:resource_id) { 'ABC123' }

      let!(:stub) do
        # /block_by_ref
        stub_url = '/block_by_ref'.gsub(':identity', resource_id)
        stub_request(:post, /.*api.gocardless.com#{stub_url}/).
          with(
            body: { foo: 'bar' },
            headers: { 'Foo' => 'Bar' }
          ).to_return(
            body: {
              'blocks' => {

                'active' => 'active-input',
                'block_type' => 'block_type-input',
                'created_at' => 'created_at-input',
                'id' => 'id-input',
                'reason_description' => 'reason_description-input',
                'reason_type' => 'reason_type-input',
                'resource_reference' => 'resource_reference-input',
                'updated_at' => 'updated_at-input',
              },
            }.to_json,
            headers: response_headers
          )
      end
    end
  end
end
