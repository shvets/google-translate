require "thor"
require 'google_translate'
require 'google_translate/version'
require 'google_translate/result_parser'

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
      translate -e ru help           # translates and gives extra information (nouns, verbs, synonyms)
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
  desc "translate text", "translates the text"
  option :say, aliases: "-s"
  option :extra, aliases: "-e"
  def translate from_lang, to_lang, text
    translator = GoogleTranslate.new

    result = translator.translate(from_lang, to_lang, text)

    result_parser = ResultParser.new result

    extra = options[:extra] ? (options[:extra] == 'true') : false

    if extra
      puts "Nouns: #{result_parser.nouns.join(", ")}"
      puts "Verbs: #{result_parser.verbs.join(", ")}"

      puts "Synonym Nouns:"

      result_parser.synonym_nouns.each do |r|
        puts "- " + r.join(", ")
      end

      puts "Synonym Verbs:"

      result_parser.synonym_verbs.each do |r|
        puts "- " + r.join(", ")
      end

      puts "Synonym Exclamations:"

      result_parser.synonym_exclamations.each do |r|
        puts "- " + r.join(", ")
      end
    end

    puts "Translation: #{result_parser.translation}"

    if result_parser.translit and result_parser.translit.size > 0
      puts "Translit: #{result_parser.translit}"
    end

    say = options[:say] ? (options[:say] == 'true') : false

    if say and !!(RUBY_PLATFORM =~ /darwin/i)
      translator.say(from_lang, text)
      translator.say(to_lang, result_parser.translation)
    end
  end

  private

  def print_languages title, list
    puts title
    puts list.join(', ')
  end

end
