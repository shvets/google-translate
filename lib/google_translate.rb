# google_translate.rb

require 'open-uri'

require 'cgi'
require 'json'

include ActionView::Helpers::TextHelper
#require 'iconv'

module Google

  Language = Struct.new(:name, :code) do
    def to_s
      "(" + code + ": " + name + ")"
    end
  end

  class Translator
    GOOGLE_TRANSLATE_SERVICE_URL = "http://translate.google.com"

    def self.Exception(*names)
      cl = Module === self ? self : Object
      names.each {|n| cl.const_set(n, Class.new(Exception))}
    end

    Exception :MissingFromLanguage, :MissingToLanguage, :MissingTextLanguage,
              :TranslateServerIsDown, :InvalidResponse, :MissingText, :MissingTestText

    def translate(from, to, from_text, options={})
      raise(MissingFromLanguage) if from.nil?
      raise(MissingToLanguage) if to.nil?
      raise(MissingTextLanguage) if from_text.nil?
      
      begin
        result = ""
        
        return concat_result(from, to, result, from_text, options)
        
      rescue Exception => e
         raise(TranslateServerIsDown)
      end
    end
    
    def concat_result(from, to, result, from_text, options)
      split_text = check_text_size(from_text)
      result << translate_helper(from, to, split_text["text"], options)
      
      if !split_text["last_text"].blank?
        concat_result(from, to, result, split_text["last_text"], options)
      end
      
      return result
    end
    
    def translate_helper(from, to, from_text, options={})

      url = GOOGLE_TRANSLATE_SERVICE_URL + "/translate_a/t?client=t&text=#{from_text}&hl=#{from}&sl=auto&tl=#{to}&multires=1&prev=btn&ssel=0&tsel=4&uptl=#{to}&alttl=#{from}&sc=1"

      open(URI.escape(url), 'User-Agent' => 'Mozilla 8.0') do |stream|
        #i = Iconv.new('UTF-8', stream.charset)

        #content = i.iconv(stream.read)
        content = stream.read

        s = content.split(',').collect {|s| s == '' ? "\"\"" : s}.join(",")

        result = JSON.parse(s)

        raise(TranslateServerIsDown) if (!result || result.empty?)

        final_result = ""

        result[0].each do |res|
          final_result << res[0]
        end

        final_result
      end
    end

    def detect_language(test_text)
      raise(MissingTextLanguage) if test_text.nil?

      begin
        url = GOOGLE_TRANSLATE_SERVICE_URL + "/translate_a/t?client=t&text=#{check_text_size(test_text)["text"]}&hl=en&sl=auto&tl=en&multires=1&prev=btn&ssel=0&tsel=4&uptl=en&alttl=en&sc=1"
       
        open(URI.escape(url), 'User-Agent' => 'Mozilla 8.0') do |stream|
         content = stream.read
         s = content.split(',').collect {|s| s == '' ? "\"\"" : s}.join(",")
         result = JSON.parse(s)

         raise(TranslateServerIsDown) if (!result || result.empty?)
         
         result[2]
         
        end
      rescue Exception => e
        raise(TranslateServerIsDown)
      end
    end
  
    def supported_languages
      fetch_languages(GOOGLE_TRANSLATE_SERVICE_URL , [])
    end

    private
    
    def check_text_size(text)
      result = {:text => text, :last_text => ""}
      
      if text.length >= 1230
    		result[:text] = truncate(text, :length => 1200, :separator => " ", :omission => "")
    		result[:last_text] = text[result[:text].length, text.length]
    	end
    	
    	return result
    end

    def fetch_languages(request, keys)
      response = {}

      open(URI.escape(request)) do |stream|
        content = stream.read

        from_languages = collect_languages content, 0, 'sl', 'gt-sl'
        to_languages = collect_languages content, 1, 'tl', 'gt-tl'

        response[:from_languages] = from_languages
        response[:to_languages] = to_languages
      end

      response
    end

    def collect_languages buffer, index, tag_name, tag_id
      languages = []

      spaces = '\s?'
      quote = '(\s|\'|")?'


      id_part = "id#{spaces}=#{spaces}#{quote}#{tag_id}#{quote}"
      name_part = "name#{spaces}=#{spaces}#{quote}#{tag_name}#{quote}"
      tabindex_part = "tabindex#{spaces}=#{spaces}#{quote}0#{quote}"
      phrase = "#{spaces}#{id_part}#{spaces}#{name_part}#{spaces}#{tabindex_part}#{spaces}"

      re1 = buffer.split(%r{<select#{phrase}>(.*)?</select>}).select{|x| x =~ %r{<option} }

      stopper = "</select></div>"

      text = re1[index]
      
      if index == 0
        pos = text.index(stopper)
        text = text[0..pos]
      end

      re2 = /<option(\s*)value="([a-z|A-Z|-]*)">([a-z|A-Z|\(|\)|\s]*)<\/option>/
      matches = text.gsub(/selected/i, '').squeeze.scan(re2)

      if matches.size == 0
        re2 = /<option(\s*)value=([a-z|A-Z|-]*)>([a-z|A-Z|\(|\)|\s]*)<\/option>/
        matches = text.gsub(/selected/i, '').squeeze.scan(re2)
      end

      matches.each do |m|
         languages << Language.new(m[2], m[1])
      end

      languages
    end
  end

end
