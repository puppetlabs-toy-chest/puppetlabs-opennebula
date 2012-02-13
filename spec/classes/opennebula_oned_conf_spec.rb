#!/usr/bin/env rspec

require 'spec_helper'

describe 'opennebula::oned_conf', :type => :class do
  # Convenience helper for returning parameters for a type from the
  # catalogue.
  #
  # TODO: find a place for this, potentially rspec-puppet.
  def get_param(type, title, param)
    catalogue.resource(type, title).send(:parameters)[param.to_sym]
  end

  let(:facts) do
    { :operatingsystem => 'debian' }
  end

  let(:params) do
    { 'oned_conf_path' => "/var/opennebula/oned.conf" }
  end

  # Hash for basic validation
  validation_hash = {
    :manager_timer => {
      :valid => [15,30,45],
    },
    :host_monitoring_interval => {
      :valid => [60,120,180],
    },
    :vm_polling_interval => {
      :valid => [0, 60, 120],
    },
    :vm_dir => {
      :valid => ["/srv/vms", "/var/lib/vms"],
    },
    :scripts_remote_dir => {
      :valid => ["/opt/scripts", "/srv/scripts"],
    },
    :port => {
      :valid => [8001, 8080],
    },
    :vnc_base_port => {
      :valid => [5900, 6900],
    },
    :debug_level => {
      :valid => [0, 1, 2, 3],
    },
    :network_size => {
      :valid => [16, 24, 29],
    },
    :mac_prefix => {
      :valid => ["02:00"],
    },
    :image_repository_path => {
      :valid => ['/srv/images'],
    },
    :default_image_type => {
      :valid => ["OS", "CDROM", "DATABLOCK"],
    },
    :default_device_prefix => {
      :valid => ["hd", "sd", "xvd", "vd"],
    },
  }

  describe 'when creating template' do
    validation_hash.each do |param, config|
      describe "param #{param.to_s}" do
        config[:valid].each do |value|
          it "should populate template with value #{value}" do
            params[param.to_s] = value
            content = get_param('file', '/var/opennebula/oned.conf', 'content')
            content.should =~ /^#{param.to_s.upcase}\s+=\s+"?#{value}"?/
          end
        end
      end
    end

    describe "params db_*" do
      it 'should populate template with db_backend value' do
        params['db_backend'] = 'sqlite'
        content = get_param('file', '/var/opennebula/oned.conf', 'content')
        content.should =~ /backend = "sqlite"/
      end

      it 'when db_backend is set to mysql should populate other fields in template' do
        params['db_backend'] = 'mysql'
        params['db_server'] = 'mydbserver'
        params['db_port'] = '9999'
        params['db_user'] = 'mydbuser'
        params['db_passwd'] = 'mydbpassword'
        params['db_name'] = 'mydbname'

        content = get_param('file', '/var/opennebula/oned.conf', 'content')

        content.should =~ /backend\s+=\s+"mysql"/
        content.should =~ /server\s+=\s+"mydbserver"/
        content.should =~ /port\s+=\s+"9999"/
        content.should =~ /user\s+=\s+"mydbuser"/
        content.should =~ /passwd\s+=\s+"mydbpassword"/
        content.should =~ /db_name\s+=\s+"mydbname"/
      end
    end
  end
end
