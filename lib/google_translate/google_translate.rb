#encoding: UTF-8

require 'net/http'
require 'uri'
require 'json'
require 'tempfile'
require 'resource_accessor'

class GoogleTranslate
  GOOGLE_TRANSLATE_SERVICE_URL = "https://translate.google.com"
  GOOGLE_SPEECH_SERVICE_URL    = "http://translate.google.com/translate_tts"

  def supported_languages
    response = call_service GOOGLE_TRANSLATE_SERVICE_URL

    from_languages = collect_languages response.body, 0, 'sl', 'gt-sl'
    to_languages   = collect_languages response.body, 1, 'tl', 'gt-tl'

    [from_languages, to_languages]
  end

  def translate(from_lang, to_lang, text)
    raise("Missing 'from' language") unless from_lang
    raise("Missing 'to' language") unless to_lang
    raise("Missing text for translation") unless text

    r = call_translate_service(from_lang, to_lang, URI.escape(text))

    result = JSON.parse(r.gsub('[,', '['))

    raise("Translate Server is down") if (!result || result.empty?)

    result
  end

  def say lang, text
    speech_content = call_speech_service(lang, text)

    file = Tempfile.new('.google_translate_speech---')

    file.write(speech_content)

    file.close

    system "afplay #{file.path}"

    file.unlink
  end

  private

  def translate_url(from_lang, to_lang)
    url = "#{GOOGLE_TRANSLATE_SERVICE_URL}/translate_a/single"
    params = "client=t&sl=#{from_lang}&tl=#{to_lang}&hl=en&dt=bd&dt=ex&dt=ld&dt=md&dt=qc&dt=rw&dt=rm&dt=ss" +
             "&dt=t&dt=at&dt=sw&ie=UTF-8&oe=UTF-8&prev=btn&rom=1&ssel=0&tsel=0"

    "#{url}?#{params}"
  end

  def speech_url(lang)
    "#{GOOGLE_SPEECH_SERVICE_URL}?tl=#{lang}&ie=UTF-8&oe=UTF-8"
  end

  def call_translate_service from_lang, to_lang, text
    url = translate_url(from_lang, to_lang)

    response = call_service url + "&q=#{text}"

    response.body.split(',').collect { |s| s == '' ? "\"\"" : s }.join(",") # fix json object
  end

  def call_speech_service lang, text
    url = speech_url(lang)

    response = call_service url + "&q=#{text}"

    response.body
  end

  def call_service url
    accessor = ResourceAccessor.new

    accessor.get_response url: url
  end

  def collect_languages buffer, index, tag_name, tag_id
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

    matches.map { |m| Language.new(m[2], m[1]) }
  end
end


