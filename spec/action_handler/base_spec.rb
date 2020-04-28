RSpec.describe ActionHandler::Base do
  describe :call do

    let(:klass) do
      Class.new(ActionHandler::Base) do
        source ActionHandler::Sources::Invoke.new

        def index
          { key: params[:key] }
        end

        def show
          render json: { key: params[:key] }
        end
      end
    end

    context :action do
      let(:event) { { 'key' => 'secret_key' } }

      context :with_render do
        let(:response) { klass.show(event: event, context: {}) }
        it 'should render response' do
          expect(response).to eq(
            statusCode: 200,
            body: "{\"key\":\"secret_key\"}",
            headers: { 'Content-Type' => 'application/json' }
          )
        end
      end

      context :without_render do
        let(:response) { klass.index(event: event, context: {}) }
        it 'should render response' do
          expect(response).to eq(statusCode: 204, headers: {})
        end
      end
    end
  end
end
