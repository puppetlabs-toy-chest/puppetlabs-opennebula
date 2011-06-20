require 'etc'

Facter.add(:oneadmin_pubkey_rsa) do
  setcode do
    ent = Etc.getpwnam("oneadmin")
    keyfile = File.open(ent.dir + "/.ssh/id_rsa.pub")
    keyarray = keyfile.read.split(" ")
    keyarray[1]
  end
end
