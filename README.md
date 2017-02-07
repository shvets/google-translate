#  Google-Translate

Client for Google Translate API

<div style="margin: 25px;">
<a href="https://rapidapi.com/package/GoogleTranslate/functions?utm_source=GoogleTranslateGitHub-Ruby&utm_medium=button&utm_content=Vendor_GitHub" style="
    all: initial;
    background-color: #498FE1;
    border-width: 0;
    border-radius: 5px;
    padding: 10px 20px;
    color: white;
    font-family: 'Helvetica';
    font-size: 12pt;
    background-image: url(https://scdn.rapidapi.com/logo-small.png);
    background-size: 25px;
    background-repeat: no-repeat;
    background-position-y: center;
    background-position-x: 10px;
    padding-left: 44px;
    cursor: pointer;">
  Run now on <b>RapidAPI</b>
</a>
</div>

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

Translates and gives extra information (nouns, verbs, synonyms):

    $ t -e ru help

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

