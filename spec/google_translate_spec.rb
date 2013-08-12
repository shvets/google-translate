# translate_spec.rb

require File.dirname(__FILE__) + '/spec_helper'

require 'google_translate'

describe GoogleTranslate do

  it "should raise an error if one of parameters is missing" do
    expect { subject.translate(nil, :ru) }.to raise_error

    expect { subject.translate(:en, nil) }.to raise_error

    expect { subject.translate(:en, :ru, nil) }.to raise_error
  end

  it "should translate test string from one language to another" do
    r = subject.translate(:en, :ru, "hello world!")
    puts r
    r.size.should be > 0
  end

  it "should translate test string from one language to another with autodetect" do
    r = subject.translate(:auto, :ru, "hello world!")
    puts r
    r.size.should be > 0
  end

  #it "should return unreliable flag if language is not recognized" do
  #  subject.detect_language("azafretmkldt")['isReliable'].should be_false
  #end

  it "should return list of supported languages" do
    languages = subject.supported_languages

    languages[:from_languages].size.should > 0
    languages[:to_languages].size.should > 0
  end
end
