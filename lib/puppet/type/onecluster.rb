Puppet::Type.newtype(:onecluster) do
  @doc = "Type for managing clusters in OpenNebula using the onecluster" +
         "wrapper command."

  ensurable
  
  newparam(:name) do
    desc "Name of cluster."
    
    isnamevar
  end
end
