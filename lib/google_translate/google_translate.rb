#encoding: UTF-8

require 'net/http'
require 'json'
require 'tempfile'

class GoogleTranslate
  GOOGLE_TRANSLATE_SERVICE_URL = "http://translate.google.com"

  def supported_languages
    response = call_service GOOGLE_TRANSLATE_SERVICE_URL

    from_languages = collect_languages response.body, 0, 'sl', 'gt-sl'
    to_languages   = collect_languages response.body, 1, 'tl', 'gt-tl'

    [from_languages, to_languages]
  end

  def translate(from_lang, to_lang, text, options={})
    raise("Missing 'from' language") unless from_lang
    raise("Missing 'to' language") unless to_lang
    raise("Missing text for translation") unless text

    result = JSON.parse(call_translate_service(from_lang, to_lang, text))

    raise("Translate Server is down") if (!result || result.empty?)

    result
  end

  def say lang, text
    speech_content = call_speech_service(lang, text)

    file = Tempfile.new('.google_translate_speech-')

    file.write(speech_content)

    file.close

    system "afplay #{file.path}"

    file.unlink
  end

  private

  def translate_url(from_lang, to_lang)
    "#{GOOGLE_TRANSLATE_SERVICE_URL}/translate_a/t?client=t&sl=#{from_lang}&tl=#{to_lang}&hl=pl&sc=2&ie=UTF-8&oe=UTF-8&prev=enter&ssel=0&tsel=0&"
  end

  def speech_url(lang)
    "#{GOOGLE_TRANSLATE_SERVICE_URL}/translate_tts?tl=#{lang}&ie=UTF-8&oe=UTF-8"
  end

  def call_translate_service from_lang, to_lang, text
    url = translate_url(from_lang, to_lang)

    response = call_service url, text

    response.body.split(',').collect { |s| s == '' ? "\"\"" : s }.join(",") # fix json object
  end

  def call_speech_service lang, text
    url = speech_url(lang)

    response = call_service url, text

    response.body
  end

  def call_service url, text=nil
    uri = URI.parse(URI.escape(url))

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(text: text)

    http.request(request)
  end

  def collect_languages buffer, index, tag_name, tag_id
    languages = []

    spaces = '\s?'
    quote  = '(\s|\'|")?'

    id_part       = "id#{spaces}=#{spaces}#{quote}#{tag_id}#{quote}"
    name_part     = "name#{spaces}=#{spaces}#{quote}#{tag_name}#{quote}"
    class_part    = "class#{spaces}=#{spaces}#{quote}(.*)?#{quote}"
    tabindex_part = "tabindex#{spaces}=#{spaces}#{quote}0#{quote}"
    phrase        = "#{spaces}#{id_part}#{spaces}#{name_part}#{spaces}#{class_part}#{spaces}#{tabindex_part}#{spaces}"

    re1 = buffer.split(%r{<select#{phrase}>(.*)?</select>}).select { |x| x =~ %r{<option} }

    stopper = "</select>"

    text = re1[index]

    if index == 0
      pos  = text.index(stopper)
      text = text[0..pos]
    end

    re2     = /<option(\s*)value="([a-z|A-Z|-]*)">([a-z|A-Z|\(|\)|\s]*)<\/option>/
    matches = text.gsub(/selected/i, '').squeeze.scan(re2)

    if matches.size == 0
      re2     = /<option(\s*)value=([a-z|A-Z|-]*)>([a-z|A-Z|\(|\)|\s]*)<\/option>/
      matches = text.gsub(/selected/i, '').squeeze.scan(re2)
    end

    matches.each do |m| languages << Language.new(m[2], m[1])
    end

    languages
  end
end


