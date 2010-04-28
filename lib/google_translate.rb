# google_translate.rb

require 'open-uri'
require 'cgi'
require 'json'

module Google
  Language = Struct.new(:name, :code) do
    def to_s
      "(" + code + ": " + name + ")"
    end
  end

  class Translator
    def self.Exception(*names)
      cl = Module === self ? self : Object
      names.each {|n| cl.const_set(n, Class.new(Exception))}
    end

    Exception :MissingFromLanguage, :MissingToLanguage, :MissingTextLanguage,
              :TranslateServerIsDown, :InvalidResponse, :MissingText, :MissingTestText

    URL_STRING = "http://ajax.googleapis.com/ajax/services/language/"
    URL2_STRING = "http://translate.google.com"

    def translate(from, to, from_text, options={})
      raise(MissingFromLanguage) if from.nil?
      raise(MissingToLanguage) if to.nil?
      raise(MissingTextLanguage) if from_text.nil?

      request = URL_STRING + "translate?v=1.0&langpair=#{from}%7C#{to}&q=" + CGI.escape(from_text) 
      
      begin
        response = call_service(request, [:response_status, :response_details, :response_data])

        raise(TranslateServerIsDown) if response.empty?

        raise(InvalidResponse, response[:response_details]) if response[:response_status] != 200 # success

        to_text = response[:response_data]['translatedText']

        (options[:html]) ? CGI.unescapeHTML(to_text) : to_text
      rescue OpenURI::HTTPError
        raise(TranslateServerIsDown)
      end
    end

    def detect_language(test_text)
      raise(MissingTestText) if test_text.nil?

      request = URL_STRING + "detect?v=1.0&q=" + CGI.escape(test_text) 

      begin
        response = call_service(request, [:response_data]) 
        response_data = response[:response_data]

        raise(TranslateServerIsDown) if response.empty?

        response_data
      rescue OpenURI::HTTPError
        raise(TranslateServerIsDown)
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

        from_languages = collect_languages content, 'sllangdropdown', 'sl', 'old_sl'
        to_languages = collect_languages content, 'tllangdropdown', 'tl', 'old_tl'

        response[:from_languages] = from_languages
        response[:to_languages] = to_languages
      end

      response
    end

    def collect_languages buffer, class_name, tag_name, tag_id
      languages = []

      spaces = '\s?'
      quote = '(\s|\'|")?'

      class_part = "class#{spaces}=#{spaces}#{quote}#{class_name}#{quote}"
      name_part = "name#{spaces}=#{spaces}#{quote}#{tag_name}#{quote}"
      id_part = "id#{spaces}=#{spaces}#{quote}old_sl#{quote}"
      tabindex_part = "tabindex#{spaces}=#{spaces}#{quote}0#{quote}"

      re1 = buffer.split(%r{<select#{spaces}#{class_part}#{spaces}#{name_part}#{spaces}#{id_part}#{spaces}#{tabindex_part}#{spaces}>(.*)?</select>}).select{|x| x =~ %r{<option} }
      text = re1[0]

      re2 = /<option(\s*)value="([a-z|A-Z]*)">([a-z|A-Z]*)<\/option>/

      matches = text.scan(re2)

      matches.each do |m|
        languages << Language.new(m[2], m[1])
      end

      languages
    end
  end

end
