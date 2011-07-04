require 'etc'

Facter.add(:oneadmin_pubkey_rsa) do
  setcode do
    # First try to grab an entry for the onadmin user from /etc/passwd
    value = nil
    begin
      ent = Etc.getpwnam("oneadmin")

      # Now grab the users public key and return the key part of it
      if File.exists?(ent.dir + "/.ssh/id_rsa.pub") then
        keyfile = File.open(ent.dir + "/.ssh/id_rsa.pub")
        keyarray = keyfile.read.split(" ")
        value = keyarray[1]
      end

    rescue Exception => e
      value = nil
    end

    value
  end
end
