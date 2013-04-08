# encoding: utf-8
require 'spec_helper'

describe Skiima::Config::Struct do
  let(:attrs) {{ foo: 'foo', bar: 'bar' }}
  subject { Skiima::Config::Struct.new(attrs) }

  describe "#initialize" do

  end

  describe "#new_ostruct_member" do

  end

  describe "#method_missing" do

  end

  describe "#[]" do
    it "returns the :value at :key" do
      subject[:foo].must_equal 'foo'
      subject[:bar].must_equal 'bar'
    end
  end

  describe "#[]=" do
    it "modifies the :value at :key" do
      subject[:foo] = 'baz'
      subject[:foo].must_equal 'baz'
    end

    it "defines new methods on the struct" do
      subject.wont_respond_to :baz
      subject[:baz] = 'baz'
      subject[:baz].must_equal 'baz'
      skip
      subject.must_respond_to :baz
    end
  end

  describe "#slice" do
    it "should slice the underlying hash" do
      subject.slice(:foo).must_equal({ foo: 'foo' })
    end
  end

  describe "#merge" do
    it "should merge with another hash" do

    end

    it "should merge with another Struct" do

    end

    it "defines new methods for each new key" do

    end
  end

  describe "to_hash" do
    it "must return the contents of the hash" do
      subject.to_hash.must_equal attrs
    end
  end

  describe "#convert_key" do
    it "must strings to symbols" do
      subject.convert_key('to_the_midway?').must_equal :to_the_midway?
    end

    it "wont modify symbols" do
      subject.convert_key(:to_the_midway?).must_equal :to_the_midway?
    end
  end

end
