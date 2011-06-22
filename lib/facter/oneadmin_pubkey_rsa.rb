require 'etc'

Facter.add(:oneadmin_pubkey_rsa) do
  setcode do
    # First try to grab an entry for the onadmin user from /etc/passwd
    begin
      ent = Etc.getpwnam("oneadmin")
    rescue Exception => e
      exit(0)
    end

    # Now grab the users public key and return the key part of it
    if File.exists?(ent.dir + "/.ssh/id_rsa.pub") then
      keyfile = File.open(ent.dir + "/.ssh/id_rsa.pub")
      keyarray = keyfile.read.split(" ")
      keyarray[1]
    end
  end
end
