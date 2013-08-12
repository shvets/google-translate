require 'google_translate'

class TranslateCli
  USAGE= <<-TEXT
    Usage:
      translate list                 - displays the list of supported languages
      translate en:ru "hello world"  - translates from en to ru
      translate ru "hello world"     - translated from auto-detected language to ru
  TEXT

  def initialize
    @translator = GoogleTranslate.new
  end

  def print_languages list, title
    puts title
    puts list.join(', ')
  end

  def display result
    r1, r2 = *result

    if r2.empty?
      puts r1
    else
      puts r1
      puts r2
    end

    # if RUBY_PLATFORM =~ /mswin32/
    # #  File.open("temp.txt", "w") {|f| f.write text }
    # #  %x[notepad temp.txt]
    #
    #   puts (r2.empty? ? r1 : r2)
    # else
    #  puts (r2.empty? ? r1 : r2)
    # end
  end

  def run params
    if(params.size == 0)
      puts USAGE
    else
      case params.shift
        when /(-v)|(--version)/ then
          puts "Version: #{File.open(File::dirname(__FILE__) + "/../VERSION").readlines().first}"
        when 'list' then
          hash = @translator.supported_languages

          print_languages hash[:from_languages], "From Languages:"
          print_languages hash[:to_languages], "To Languages:"
        when /(.*):(.*)/ then
          from_text = params.join(' ')
          from = $1
          to = $2

          display(@translator.translate(from.to_sym, to.to_sym, from_text))
        when /(.*)/ then
          from_text = params.join(' ')

          from = "auto"
          to = $1

          begin
            display(@translator.translate(from.to_sym, to.to_sym, from_text))
          rescue Exception => e
            puts "Error: " + e.message
          end
      end
    end
  end
end