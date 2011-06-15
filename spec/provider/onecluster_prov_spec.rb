require 'spec_helper'

provider_class = Puppet::Type.type(:onecluster).provider(:onecluster)
describe provider_class do
  before :each do
    @resource = Puppet::Type::Onecluster.new({
      :name => 'new_cluster', 
    })
    @provider = provider_class.new(@resource)
  end
  
  it 'should match jump' do
    @provider
  end
end
