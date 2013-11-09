require "thor"
require 'google_translate'
require 'google_translate/version'

class TranslateCLI < Thor
  USAGE = <<-LONGDESC
    Simple client for Google Translate API.

    Usage:
      translate                      # displays usage
      translate -v                   # displays the version
      translate list                 # displays the list of supported languages
      translate en:ru Hello world    # translates from English to Russian
      translate ru Hello world       # translates to Russian from auto-detected language
      translate -s ru Hello world    # translates and tries to say it
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

    puts "Translation: #{translation}"
    puts "Translit: #{translit}" unless translit.size == 0

    display_synonyms(result)

    say = options[:say] ? (options[:say] == 'true') : false

    if say and !!(RUBY_PLATFORM =~ /darwin/i)
      translator.say(from_lang, text)
      translator.say(to_lang, translation)
    end
  end

  private

  def display_synonyms result
    if result[5].size > 5
      synonyms = result[5][0][2]

      if synonyms.size > 1
        puts "Synonyms:"

        (1..synonyms.size-1).each do |index|
          puts synonyms[index][0]
        end
      end
    end
  end

  def print_languages title, list
    puts title
    puts list.join(', ')
  end

end
