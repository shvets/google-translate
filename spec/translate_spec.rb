# translate_spec.rb

require File.dirname(__FILE__) + '/spec_helper'

require 'google_translate'

module Google

  describe Translator do
    before :each do
      @translator = Translator.new
    end

    it "should raise an error if one of parameters is missing" do
      lambda {
        @translator.translate(nil, :ru)
      }.should raise_error

      lambda {
        @translator.translate(:en, nil)
      }.should raise_error

      lambda {
        @translator.translate(:en, :ru, nil)
      }.should raise_error
    end
    
    it "should translate test string from one language to another" do
      r = @translator.translate(:en, :ru, "hello world!")

      puts r

      r.size.should be > 0
    end

    it "should detect the language of a string" do
      @translator.detect_language("bonjour tout le monde")['language'].should be == "fr"
    end
     
    it "should raise an error if no string" do
      lambda {
        @translator.detect_language(nil)
      }.should raise_error
    end
    
    it "should return unreliable flag if language is not recognized" do
      @translator.detect_language("azafretmkldt")['isReliable'].should be_false
    end

    it "should return list of supported languages" do
      languages = @translator.supported_languages

      languages[:from_languages].size.should > 0
      languages[:to_languages].size.should > 0
    end
  end

end
