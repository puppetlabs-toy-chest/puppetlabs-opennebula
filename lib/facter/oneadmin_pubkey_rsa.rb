require 'etc'

ent = Etc.getpwnam("oneadmin")
if File.exists?(ent.dir + "/.ssh/id_rsa.pub") then

  Facter.add(:oneadmin_pubkey_rsa) do
    setcode do
      keyfile = File.open(ent.dir + "/.ssh/id_rsa.pub")
      keyarray = keyfile.read.split(" ")
      keyarray[1]
    end
  end

end