Puppet::Type.newtype(:onehost) do
  @doc = "Type for managing host in OpenNebula using the onehost" +
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
    desc "Name of host."

    isnamevar
  end

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
