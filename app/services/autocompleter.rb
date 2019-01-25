class Autocompleter
  MODELS_TO_SEARCH = [Micropost].freeze
  attr_accessor :query # refers to @query, providing the getter and setter
  def initialize(query)
    @query = query
  end

  def self.call(query)
    new(query).call
  end

  def call
    results.map do |result|
      {
        primary: result.highlight,
        # secondary: build_result(result)
      }
    end
  end

  def build_result(record)
    ResultBuilder.call(record)
  end

  private

  def results
     Elasticsearch::Model.search(search_query, MODELS_TO_SEARCH).results
  end

  def search_query
    {
      "size": 50,
      "query": {
        "function_score": {
          "query": {
            "bool": {
              "must": [multi_match]
            }
          },
          "functions": priorities
        }
      },
      "highlight": {
        "fields": {
          "content": {}
        }
      }
    }
  end
  def multi_match
    {
      "multi_match": {
        "query": @query,
        "fields": %w[content user_id name email],
        "fuzziness": 'auto'
      }
    }
  end
  def priorities
    [
      {
        "filter": {
          "term": { "_type": 'Micropost' }
        },
        "weight": 5000
      }
    ]
  end
end