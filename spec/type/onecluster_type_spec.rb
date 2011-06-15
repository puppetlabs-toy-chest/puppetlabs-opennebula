require 'spec_helper'

describe Puppet::Type.type(:onecluster) do
  before :each do
    @resource = Puppet::Type.type(:onecluster).new({
      :name => 'new_resource',
    })
  end

  it 'should accept a name' do
    @resource[:name] = '000-test-foo'
    @resource[:name].should == '000-test-foo'
  end
end
