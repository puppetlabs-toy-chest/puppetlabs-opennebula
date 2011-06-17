#!/usr/bin/env ruby

require 'dnsruby'

# Args
zone = ARGV[0]
ns = ARGV[1]
host = ARGV[2]

# Resolver for local host
res = Dnsruby::Resolver.new({:nameserver => ns})

# Clear
clear = Dnsruby::Update.new(zone)
clear.present(host)
clear.delete(host)

begin
  reply = res.send_message(clear)
rescue Exception => e
  print "Clear failed: #{e}\n"
end
