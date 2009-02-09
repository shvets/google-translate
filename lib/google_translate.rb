# google_translate.rb

require 'open-uri'
require 'cgi'
require 'json'

module Google
  class Language
    attr_reader :name, :code

    def initialize(name, code)
      @name = name
      @code = code
    end

    def to_s
      "(" + @code + ": " + @name + ")"
    end
  end

  class Translator
    URL_STRING = "http://ajax.googleapis.com/ajax/services/language/"
    URL2_STRING = "http://translate.google.com"

    def translate(from, to, from_text, options={})
      raise Exception.new :missing_from_language if from.nil?
      raise Exception.new :missing_to_language if to.nil?
      raise Exception.new :missing_text if from_text.nil?

      request = URL_STRING + "translate?v=1.0&langpair=#{from}%7C#{to}&q=" + CGI.escape(from_text) 
      
      begin
        response = call_service(request, [:response_status, :response_details, :response_data])

        raise Exception.new :translate_server_is_down if response.empty?

        raise Exception.new response[:response_details] if response[:response_status] != 200 # success

        to_text = response[:response_data]['translatedText']

        to_text = encode_text(to_text) if to == :ru

        (options[:html]) ? CGI.unescapeHTML(to_text) : to_text
      rescue OpenURI::HTTPError
        raise Exception.new :translate_server_is_down
      end
    end

    def detect_language test_text
      raise Exception.new :missing_test_text if test_text.nil?

      request = URL_STRING + "detect?v=1.0&q=" + CGI.escape(test_text) 

      begin
        response = call_service(request, [:response_data]) 
        response_data = response[:response_data]

        raise Exception.new :translate_server_is_down if response.empty?
        #raise Exception.new :unreliable_detection if !response_data['isReliable']

        response_data
      #
      rescue OpenURI::HTTPError
        raise Exception.new :translate_server_is_down
      end
    end
  
    def supported_languages
      call_service2(URL2_STRING , [])
    end

    private

    def camelize(str)
      words = str.split('_')

      words[0] + words[1..-1].map {|w| w.capitalize}.join
    end

    def call_service(request, keys)
      response = {}

      open(request) do |stream|
        content = stream.read

        unless content.nil?
          json = JSON.parse(content)

          keys.each do |key|
            response[key] = json[camelize(key.to_s)]
          end
        end
      end

      response
    end

    def call_service2(request, keys)
      response = {}

      open(URI.escape(request)) do |stream|
        content = stream.read

        from_languages = collect_languages content, 'sl', 'old_sl'
        to_languages = collect_languages content, 'tl', 'old_tl'

        response[:from_languages] = from_languages
        response[:to_languages] = to_languages
      end

      response
    end

    def collect_languages buffer, tag_name, tag_id
      languages = []

      spaces = '\s?'
      quote = '(\s|\'|")?'
      text = '(.*)'

      re1 = /<select#{spaces}name=#{quote}#{tag_name}#{quote}#{spaces}id=#{quote}#{tag_id}#{quote}#{spaces}tabindex=0>(.*)<\/select>/
      text = re1.match(buffer)[5]

      re2 = /<option(\s*)value="([a-z|A-Z]*)">([a-z|A-Z]*)<\/option>/

      matches = text.scan(re2)

      matches.each do |m|
        languages << Language.new(m[2], m[1])
      end

      languages
    end

    def encode_text text
      s = ''
      text.unpack("U*").each do |ch|
        if (1072..1087).include? ch
          s << (ch-912).chr
        elsif (1088..1103).include? ch
          s << (ch-864).chr
        elsif (1020..1071).include? ch
          s << (ch-892).chr
        else
          s << ch
        end
      end

      s
    end
  end

end
