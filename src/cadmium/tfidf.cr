require "./tokenizer/word_tokenizer"
require "./util/stop_words"
require "random"
require "apatite"

module Cadmium
  class TfIdf
    include Cadmium::Util::StopWords

    # TODO: Figure out how to make this work with no key
    alias Document = NamedTuple(key: String, terms: Hash(String, Float64))

    @documents : Array(Document)
    @idf_cache : Hash(String, Float64)
    @stop_words : Array(String)
    @tokenizer : Cadmium::WordTokenizer

    def initialize(documents : Array(Document)? = nil)
      @documents = documents || [] of Document
      @idf_cache = {} of String => Float64
      @stop_words = @@stop_words
      @tokenizer = Cadmium::WordTokenizer.new
    end

    def tfidf(terms, d)
      if terms.is_a?(String)
        terms = @tokenizer.tokenize(terms)
      end

      terms.reduce(0.0) do |value, term|
        _idf = idf(term)
        _idf = _idf.infinite? ? 0.0 : _idf
        value + TfIdf.tf(term, @documents[d]) * _idf
      end
    end

    def add_document(text : String | Array(String), key = nil, restore_cache = false)
      key ||= Random::Secure.hex(4)
      @documents.push(build_document(text, key))

      if restore_cache
        @idf_cache.each { |(term, _)| idf(term, true) }
      else
        @idf_cache = {} of String => Float64
      end
    end

    def tfidfs(terms)
      Array(Float64).new(@documents.size, 0.0).map_with_index do |_, i|
        tfidf(terms, i)
      end
    end

    def tfidfs(terms, &block)
      tfidfs = Array(Float64).new(@documents.size, 0.0)

      @documents.each_with_index do |doc, i|
        tfidfs[i] = tfidf(terms, i)

        yield(i, tfidfs[i], doc[:key])
      end

      tfidfs
    end

    def stop_words=(value)
      @stop_words = value
    end

    def self.tf(term : String, document : Document)
      document[:terms].has_key?(term) ? document[:terms][term] : 0.0
    end

    def idf(term : String, force = false)
      if @idf_cache.has_key?(term) && !force
        return @idf_cache[term]
      end

      docs_with_term = @documents.reduce(0) { |count, doc| count + (document_has_term(doc, term) ? 1.0 : 0.0) }
      idf = 1 + Math.log(@documents.size / (1.0 + docs_with_term))
      @idf_cache[term] = idf
      idf
    end

    def list_terms(d)
      terms = [] of NamedTuple(term: String, tfidf: Float64)

      return terms unless @documents[d]?

      @documents[d][:terms].each do |(key, _)|
        terms.push({term: key, tfidf: tfidf(key, d)})
      end

      terms.sort_by { |x| -x[:tfidf] }
    end

    def lexrank_summary(summary_length, threshold = 0.2)
      s = documents.keys.join # Full corpus
      sentences = Cadmium::Util::Sentence.sentences(s)
      n = sentences.size # Number of sentences
      # Vector of Similarity Degree for each sentence in the corpus
      degree = Array.new(n) { 0.00 }

      # Square matrix of dimension n = number of sentences
      cosine_matrix = Matrix.build(n) do |i, j|
        if idf_modified_cosine(s[i], s[j]) > threshold
          degree[i] += 1.0
          1.0
        else
          0.0
        end
      end

      # Similarity Matrix
      similarity_matrix = Matrix.build(n) do |i, j|
        degree[i] == 0 ? 0.0 : (cosine_matrix[i, j] / degree[i])
      end

      # Random walk ala PageRank
      # in the form of a power method
      results = power_method similarity_matrix, n, 0.85

      # Ugly sleight of hand to return a text based on results
      # <Array>Results => <Hash>Results => <String>ResultsText
      h = Hash[@sentences.zip(results)]
      h.sort_by { |k, v| v }.reverse.first(summary_length).to_h.keys.join(" ")
    end

    private def sentence_tfidf_sum(sentence) # For lexrank
      # The Sum of tfidf values for each of the words in a sentence
      sentence.split(" ")
        .map { |word| (tf(sentence, word)**2) * idf(word) }
        .inject(:+)
    end

    private def idf_modified_cosine(x, y) # For lexrank
      # Compute the similarity between two sentences x, y
      # using the modified cosine tfidf formula
      numerator = (x + " " + y).split(" ")
        .map { |word| tf(x, word) * tf(y, word) * (idf(word)**2) }
        .inject(:+)

      denominator = Math.sqrt(sentence_tfidf_sum(x)) * Math.sqrt(sentence_tfidf_sum(y))
      numerator / denominator
    end

    def power_method(matrix, n, e) # For lexrank
      # Accept a stochastic, irreducible & aperiodic matrix M
      # Accept a matrix size n, an error tolerance e
      # Output Eigenvector p

      # init values
      t = 0
      p = Vector.elements(Array.new(n) { (1.0 / n) * 1 })
      sigma = 1

      until sigma < e
        t += 1
        prev_p = p.clone
        p = matrix.transpose * prev_p
        sigma = (p - prev_p).norm
      end

      p.to_a
    end

    private def build_document(text, key)
      stopout = false

      if text.is_a?(String)
        text = @tokenizer.tokenize(text)
        stopout = true
      end

      text.reduce({key: key, terms: {} of String => Float64}) do |document, term|
        document[:terms][term] = 0.0 unless document[:terms].has_key?(term)
        if !stopout || @stop_words.includes?(term) == false
          document[:terms][term] = document[:terms][term] + 1.0
        end
        document
      end
    end

    private def document_has_term(document : Document, term)
      document[:terms].has_key?(term) && document[:terms][term] > 0.0
    end
  end
end
