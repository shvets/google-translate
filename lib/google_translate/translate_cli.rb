require "thor"
require 'google_translate'
require 'google_translate/version'

class TranslateCLI < Thor
  USAGE = <<-LONGDESC
    Simple client for Google Translate API.

    Usage:
      translate -v                   - displays the version
      translate list                 - displays the list of supported languages
      translate en:ru "hello world"  - translates from en to ru
      translate ru "hello world"     - translated from auto-detected language to ru
  LONGDESC

  desc "version", "displays version"
  def version
    puts "Google Translate Version: #{GoogleTranslate::VERSION}"
  end

  desc "list", "displays the list of supported languages"
  def list
    translator = GoogleTranslate.new

    from_languages, to_languages = translator.supported_languages

    print_languages "From Languages:", from_languages
    print_languages "To Languages:", to_languages
  end

  long_desc USAGE
  desc "thanslate text", "thanslates the text"
  option :say, :aliases => "-s"
  def translate from_lang, to_lang, text
    translator = GoogleTranslate.new

    result = translator.translate(from_lang, to_lang, text)

    translation = result[0][0][0]
    translit = result[0][0][2]
    synonyms = result[5][0]

    puts "Translation: #{translation}"

    display_synonyms(synonyms)

    say = options[:say] ? (options[:say] == 'true') : false

    if say and !!(RUBY_PLATFORM =~ /darwin/i)
      translator.say(from_lang, text)
      translator.say(from_lang, translit)
    end
  end

  private

  def display_synonyms synonyms
    puts "Synonyms:"

    synonyms_size = synonyms[1].to_i

    (1..synonyms_size).each do |index|
      puts synonyms[2][index][0]
    end
  end

  def print_languages title, list
    puts title
    puts list.join(', ')
  end

end
