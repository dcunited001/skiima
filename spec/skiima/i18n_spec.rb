require 'spec_helper'

describe Skiima::I18n do
  subject { Skiima }

  describe "#msg" do
    it "should default to using the locale specified in config block" do
      skip
      subject.msg('messages', 'create', 'start').must_equal "Creating objects for @class"
    end
  end

  describe "#default_locale" do
    it "should return the locale set for Skiima" do
      subject.expects(:locale)
      subject.default_locale
    end
  end

  describe "#set_translation_repository" do
    it "sets up FastGetText for Skiima and sets the current locale" do
      FastGettext.expects(:add_text_domain)
      subject.expects(:text_domain=).with('skiima')
      subject.expects(:locale=).with(subject.locale)
      subject.set_translation_repository
    end
  end

end
