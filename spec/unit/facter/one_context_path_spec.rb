#!/usr/bin/env rspec

require 'spec_helper'

describe "one_context_path fact" do
  it "should return context path" do
    Facter.fact(:one_context_path).value.should == "/srv/onecontext/context.sh"
  end
end
