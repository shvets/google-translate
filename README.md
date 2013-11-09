#  Google-Translate

Client for Google Translate API

## Installation

Add this line to your application's Gemfile:

    gem 'google-translate'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install google-translate

## Usage


Displays the version:

    $ t -v

Displays the list of supported languages:

    $ t list

Translates from English to Russian language:

    $ t en:ru hello world

Translates to Russian from auto-detected language:

    $ t ru hello world

Translates and tries to say it:

    $ t -s ru hello world

or

    $ ts ru hello world

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

