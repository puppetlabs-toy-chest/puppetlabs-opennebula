Puppet::Type.type(:onecluster).provide(:onecluster) do
  desc "onecluster provider"
  
  commands :onecluster => "onecluster"
  
  def create
    onecluster "create", resource[:name]
  end
  
  def destroy
    onecluster "destroy", resource[:name]
  end
  
  def exists?
    system("onecluster list | grep ' #{a}$'")
  end
end