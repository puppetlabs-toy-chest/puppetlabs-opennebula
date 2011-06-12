Puppet::Type.newtype(:onecluster) do
  @doc = "Type for managing clusters in OpenNebula using the onecluster" +
         "wrapper command."
  
  ensurable do
    newvalue(:present) do
      provider.create
    end
    
    newvalue(:absent) do
      provider.destroy
    end
    
    defaultto :present
  end
  
  newparam(:name) do
    desc "Name of cluster."
    
    isnamevar
  end
end