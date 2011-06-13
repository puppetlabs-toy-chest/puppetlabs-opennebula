Puppet::Type.newtype(:onehost) do
  @doc = "Type for managing host in OpenNebula using the onehost" +
         "wrapper command."

  ensurable
  
  newparam(:name) do
    desc "Name of host."
    
    isnamevar
  end
  
  #<im_mad> <vmm_mad> <tm_mad>
  newparam(:im_mad) do
    desc "Information Driver"
  end
  
  newparam(:vm_mad) do
    desc "Virtualization Driver"
  end
  
  newparam(:tm_mad) do
    desc "Transfer Driver"
  end
end
