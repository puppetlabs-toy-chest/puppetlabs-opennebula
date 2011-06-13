require 'rexml/document'
require 'tempfile'
require 'erb'

Puppet::Type.type(:onevnet).provide(:onevnet) do
  desc "onevnet provider"
  
  commands :onevnet => "onevnet"
  
  # Create a network with onevnet by passing in a temporary template.
  def create
    file = Tempfile.new("onevnet-#{resource[:name]}")
    template = ERB.new <<-EOF
NAME = "<%= resource[:name] %>"
TYPE = <%= resource[:type].upcase %>
BRIDGE = <%= resource[:bridge] %>

<% if resource[:type].upcase == "FIXED" %>
  <% resource[:leases].each { |lease| %>
LEASES = [IP=<%= lease%>]
  <% end %>
<% elsif reource[:type].upcase == "RANGED" %>
NETWORK_SIZE = <%= resource[:network_size] %>
NETWORK_ADDRESS = <%= resource[:network_address] %>
<% end %>
EOF

    file.write(template)
    onevnet "create", file.path
  end
  
  # Destroy a network using onevnet delete
  def destroy
    onevnet "delete", resource[:name]
  end

  # Return a list of existing networks using the onevnet -x list command
  def onevnet_list
    xml = REXML::Document.new(`onevnet -x list`)
    onevnets = []
    xml.elements.each("VNET_POOL/VNET/NAME") do |element| 
      onevnets << element.text 
    end
    onevnets
  end
    
  # Check if a network exists by scanning the onevnet list
  def exists?
    onevnet_list().include?(resource[:name])
  end

  # Return the full hash of all existing onevnet resources
  def self.instances
    instances = []
    onevnet_list.each do |vnet|
      hash = {}
        
      # Obvious resource attributes  
      hash[:provider] = self.name.to_s 
      hash[:vnet] = host
      
      # Open onevnet xml output using REXML
      xml = REXML::Document.new(`onevnet -x show #{resource[:name]}`)
        
      # Traverse the XML document and populate the common attributes
      xml.elements.each("VNET/TYPE") { |element| 
        hash[:type] = element.text == "1" ? "fixed" : "ranged" 
      }
      xml.elements.each("VNET/BRIDGE") { |element| 
        hash[:bridge] = element.text 
      }
      xml.elements.each("VNET/PUBLIC") { |element| 
        hash[:public] = element.text == "1" ? true : false 
      }
                
      # Populate ranged or fixed specific resource attributes
      if hash[:type] == "ranged" then
        xml.elements.each("VNET/TEMPLATE/NETWORK_SIZE") { |element| 
          hash[:network_size] = element.text 
        }
        xml.elements.each("VNET/TEMPLATE/NETWORK_ADDRESS") { |element| 
          hash[:network_address] = element.text 
        }
      elsif hash[:type] == "fixed" then
        hash[:leases] = []
        xml.elements.each("VNET/LEASES/LEASE/IP") { |element| 
          hash[:leases] << element.text 
        }
      end
      
      instances << new(hash)
    end

    instances
  end
end
