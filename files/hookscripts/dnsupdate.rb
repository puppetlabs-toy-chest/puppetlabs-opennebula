#!/usr/bin/env ruby

require 'dnsruby'

# Args
zone = ARGV[0]
ns = ARGV[1]
host = ARGV[2]
arecord = ARGV[3]

# Resolver for local host
res = Dnsruby::Resolver.new({:nameserver => ns})

# Clear
clear = Dnsruby::Update.new(zone)
clear.present(host, 'A')
clear.delete(host)

# Update
update = Dnsruby::Update.new(zone)
update.absent(host, 'A')
update.add(host, 'A', 0, arecord)

begin
  reply = res.send_message(clear)
rescue Exception => e
  print "Clear failed: #{e}\n"
end

begin
  reply = res.send_message(update)
rescue Exception => e
  print "Update failed: #{e}\n"
end


