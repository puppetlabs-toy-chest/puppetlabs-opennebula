Puppet::Type.type(:onecluster).provide(:onecluster) do
  desc "onecluster provider"
  
  commands :onecluster => "onecluster"
  
  def create
    onecluster "create", resource[:name]
  end
  
  def destroy
    onecluster "delete", resource[:name]
  end
  
  def exists?
    system("onecluster list | grep ' #{resource[:name]}$' > /dev/null")
  end

  def self.instances
    rules = []

    clusters = `onecluster list | grep -v ID | awk  '{print $2}'`
    clusters.split("\n").each do |cluster|
      hash = {}
      hash[:provider] = self.name.to_s 
      hash[:name] = cluster
      rules << new(hash)
    end

    rules
  end
end
