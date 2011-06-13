require 'rexml/document'
require 'tempfile'
require 'erb'

Puppet::Type.type(:onevm).provide(:onevm) do
  desc "onevm provider"
  
  commands :onevm => "onevm"
  
  # Create a VM with onevm by passing in a temporary template.
  def create
    file = Tempfile.new("onevm-#{resource[:name]}")
    template = ERB.new <<-EOF
NAME = "<%= resource[:name] %>"
MEMORY = <%= resource[:memory] %>
CPU = <%= resource[:cpu] %>
VCPU = <%= resource[:vcpu] %>

OS = [ KERNEL     = <%= resource[:os_kernel] %>,
       ARCH       = <%= resource[:os_arch] %>,
       INITRD     = <%= resource[:os_initrd] %>,
       ROOT       = <%= resource[:os_root] %>,
       KERNEL_CMD = <%= resource[:os_kernel_cmd] %>,
       BOOTLOADER = <%= resource[:os_bootloader] %>,
       BOOT       = <%= resource[:os_boot] %>,
]

<% resource[:disks].each { |disk| %>
  <% if disk[:image] %>
DISK = [ IMAGE    = <%= disk[:image] %>,
         TARGET   = <%= disk[:target] %>,
         BUS      = <%= disk[:bus] %>,
         DRIVER   = <%= disk[:driver] %>
]    
  <% else %>
DISK = [ TYPE     = <%= disk[:type] %>,
         SOURCE   = <%= disk[:source] %>,
         SIZE     = <%= disk[:size] %>,
         FORMAT   = <%= disk[:format] %>,
         TARGET   = <%= disk[:target] %>,
         CLONE    = <%= disk[:clone] == true ? "yes" : "no" %>,
         SAVE     = <%= disk[:save] == true ? "yes" : "no" %>,
         READONLY = <%= disk[:readonly] == true ? "yes" : "no" %>,
         BUS      = <%= disk[:bus] %>,
         DRIVER   = <%= disk[:driver] %>
]
  <% end %>
EOF

    tempfile = template.result(binding)
    debug("template is:\n#{tempfile}")
    file.write(tempfile)
    file.close
    onevm "create", file.path
  end
  
  # Destroy a VM using onevm delete
  def destroy
    onevm "delete", resource[:name]
  end

  # Return a list of existing VM's using the onevm -x list command
  def self.onevm_list
    xml = REXML::Document.new(`onevm -x list`)
    onevm = []
    xml.elements.each("VM_POOL/VM/NAME") do |element| 
      onevm << element.text 
    end
    onevm
  end
    
  # Check if a VM exists by scanning the onevm list
  def exists?
    self.class.onevm_list().include?(resource[:name])
  end

  # Return the full hash of all existing onevm resources
  def self.instances
    instances = []
    onevm_list.each do |vm|
      hash = {}
        
      # Obvious resource attributes  
      hash[:provider] = self.name.to_s 
      hash[:name] = vm
      
      # Open onevnet xml output using REXML
      xml = REXML::Document.new(`onevm -x show #{vnet}`)
        
      # Traverse the XML document and populate the common attributes
      xml.elements.each("VM/MEMORY") { |element| 
        hash[:memory] = element.text
      }
      xml.elements.each("VM/CPU") { |element| 
        hash[:cpu] = element.text
      }
      xml.elements.each("VM/VCPU") { |element| 
        hash[:vcpu] = element.text
      }
                  
      instances << new(hash)
    end

    instances
  end
end
