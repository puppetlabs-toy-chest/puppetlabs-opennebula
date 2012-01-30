#!/usr/bin/env rspec

require 'spec_helper'

describe 'opennebula::controller', :type => :class do
  # Convenience helper for returning parameters for a type from the
  # catalogue.
  #
  # TODO: find a place for this, potentially rspec-puppet.
  def get_param(type, title, param)
    catalogue.resource(type, title).send(:parameters)[param.to_sym]
  end

  # An operatingsystem must be defined for most things to work, and since we
  # only really officially support Debian and Ubuntu for now lets set it to
  # that.
  let(:facts) do
    { :operatingsystem => 'debian' }
  end

  describe 'when only the mandatory parameters are provided' do
    let(:params) do
      # The oneadmin_password field is mandatory
      { :oneadmin_password => 'mypassword' }
    end

    # TODO: if we can work out how to mock these, I see a pattern we can use to
    # do this more efficiently.
    pending 'it should install the packages based on the params lookup' do
      # TODO: Need to figure out how to mock the params lookup:

      # scope.lookupvar('opennebula::params::controller_package').returns('foo')
      # subject.should create_package('foo')
    end

    pending 'it should manage the services based on the params lookup' do
      # TODO: same problem as packages
    end
    # TODO: ... and the rest

    describe 'Class["opennebula::oned_config"]' do
      it 'should always be included' do
        subject.should contain_class('opennebula::oned_conf')
      end

      pending 'should be called with no params' do
        # TODO: Can't see how to do this in rspec-puppet yet
      end
    end

    describe 'Onecluster["default"]' do
      it 'should always be created' do
        subject.should contain_onecluster('default')
      end
    end
  end

  describe 'when you adjust a parameter' do
    let(:params) do
      # The oneadmin_password field is mandatory
      { :oneadmin_password => 'mypassword' }
    end

    # We only really officially support Debian and Ubuntu for now
    let(:facts) do
      { :operatingsystem => 'debian' }
    end

    ##################
    # Primary config #
    ##################

    describe 'oneadmin_password' do
      it 'should be used in the onadmin_authfile file' do
        params[:oneadmin_home] = "/var/opennebula"
        params[:oneadmin_password] = "mytestpassword"
        content = get_param("file", "/var/opennebula/.one/one_auth", "content")
        content.should =~ /mytestpassword/
      end
    end

    describe 'oned_config' do
      it 'should always include the oned_config sub-class' do
        params[:oned_config] = { 'db_backend' => 'mysql' }
        subject.should include_class('opennebula::oned_conf')
      end

      it 'should pass on parameters directly to the oned_config sub-class' do
        # Not sure if the include_class matcher supports this yet
        params[:oned_config] = { 'db_backend' => 'mysql' }
        subject.should create_class('opennebula::oned_conf').
          with_db_backend('mysql')
      end
    end

    #####################
    # Advanced Tunables #
    #####################

    describe 'controller_package' do
      it 'should override the package that gets installed' do
        params[:controller_package] = 'opennebula'
        subject.should contain_package('opennebula')
      end
    end

    describe 'controller_service' do
      it 'should override the service that gets started' do
        params[:controller_service] = 'opennebula'
        subject.should contain_service('opennebula')
      end
    end

    describe 'controller_user' do
      it 'should override the owners of various files' do
        params[:oneadmin_home] = "/var/oneadmin"
        params[:controller_user] = "user1"
        subject.should contain_file("/var/oneadmin/.one/one_auth").
          with_owner('user1')
      end
    end

    describe 'controller_group' do
      it 'should override the groups of various files' do
        params[:oneadmin_home] = "/var/oneadmin"
        params[:controller_group] = "group1"
        subject.should contain_file("/var/oneadmin/.one/one_auth").
          with_group('group1')
      end
    end

    describe 'oneadmin_home' do
      it 'should prefix the file path of File[$oneadmin_authfile]' do
        params[:oneadmin_home] = "/var/oneadmin"
        subject.should contain_file("/var/oneadmin/.one/one_auth")
      end

      it 'should prefix the file path of File[$oneadmin_ssh_config]' do
        params[:oneadmin_home] = "/var/oneadmin"
        subject.should contain_file("/var/oneadmin/.ssh/config")
      end
    end


    #####################
    # Resource creators #
    #####################

    describe 'clusters' do
      it 'when supplied a scalar should create a single onecluster resource' do
        params[:clusters] = 'cluster1'
        subject.should contain_onecluster('cluster1')
      end

      it 'when supplied an array should create multiple onecluster resources' do
        params[:clusters] = ['cluster1', 'cluster2']
        subject.should contain_onecluster('cluster1')
        subject.should contain_onecluster('cluster2')
      end
    end

    describe 'cluster_purge' do
      it 'should enable onecluster purging when enabled' do
        params[:cluster_purge] = true
        subject.should contain_resources('onecluster').with_purge(true)
      end
    end

    describe 'hosts' do
      pending 'should fail when passed anything but a hash or undef' do
        # params[:hosts] = []
      end

      it 'when supplied a hash with a single entry should create one onehost resource' do
        hosts = { 'onehost1' => {} }
        params[:hosts] = hosts
        subject.should contain_onehost('onehost1')
      end

      it 'when supplied a hash with multiple entries should create multiple resources' do
        hosts = { 'onehost1' => {}, 'onehost2' => {} }
        params[:hosts] = hosts
        subject.should contain_onehost('onehost1')
        subject.should contain_onehost('onehost2')
      end

      it 'when supplied a hash of entries with parameters should pass parameters to onehost resources' do
        hosts = {
          'onehost1' => {
            'im_mad' => 'im_kvm',
            'vm_mad' => 'vm_ssh',
          },
          'onehost2' => {
            'ensure' => 'absent',
          }
        }
        params[:hosts] = hosts
        subject.should contain_onehost('onehost1').with(hosts['onehost1'])
      end
    end

    describe 'host_purge' do
      it 'should enable purging when enabled' do
        params[:host_purge] = true
        subject.should contain_resources('onehost').with_purge(true)
      end
    end

    describe 'networks' do
      pending 'should fail when passed anything but a hash or undef' do
        # params[:networks] = []
      end

      it 'when supplied a hash with a single entry should create one resource' do
        networks = { 'onevnet1' => {} }
        params[:networks] = networks
        subject.should contain_onevnet('onevnet1')
      end

      it 'when supplied a hash with multiple entries should create multiple resources' do
        networks = { 'onevnet1' => {}, 'onevnet2' => {} }
        params[:networks] = networks
        subject.should contain_onevnet('onevnet1')
        subject.should contain_onevnet('onevnet2')
      end

      it 'when supplied a hash of entries with parameters should pass parameters to resources' do
        networks = {
          'onevnet1' => {
            'ensure' => 'present',
            'type' => 'fixed',
            'bridge' => 'vlan214',
          },
          'onevnet2' => {
            'ensure' => 'present',
            'network_size' => 'C',
          }
        }
        params[:networks] = networks
        subject.should contain_onevnet('onevnet1').with(networks['onevnet1'])
      end
    end

    describe 'network_purge' do
      it 'should enable purging when enabled' do
        params[:network_purge] = true
        subject.should contain_resources('onevnet').with_purge(true)
      end
    end

    describe 'vms' do
      pending 'should fail when passed anything but a hash or undef' do
        # params[:vms] = []
      end

      it 'when supplied a hash with a single entry should create one resource' do
        vms = { 'onevm1' => {} }
        params[:vms] = vms
        subject.should contain_onevm('onevm1')
      end

      it 'when supplied a hash with multiple entries should create multiple resources' do
        vms = { 'onevm1' => {}, 'onevm2' => {} }
        params[:vms] = vms
        subject.should contain_onevm('onevm1')
        subject.should contain_onevm('onevm2')
      end

      it 'when supplied a hash of entries with parameters should pass parameters to resources' do
        vms = {
          'onevm1' => {
            'ensure' => 'present',
            'memory' => '256',
          },
          'onevm2' => {
            'ensure' => 'present',
            'memory' => '512',
            'cpu' => 3,
          }
        }
        params[:vms] = vms
        subject.should contain_onevm('onevm1').with(vms['onevm1'])
      end
    end

    describe 'vm_purge' do
      it 'should enable purging when enabled' do
        params[:vm_purge] = true
        subject.should contain_resources('onevm').with_purge(true)
      end
    end

    describe 'images' do
      pending 'should fail when passed anything but a hash or undef' do
        # params[:images] = []
      end

      it 'when supplied a hash with a single entry should create one resource' do
        images = { 'oneimage1' => {} }
        params[:images] = images
        subject.should contain_oneimage('oneimage1')
      end

      it 'when supplied a hash with multiple entries should create multiple resources' do
        images = { 'oneimage1' => {}, 'oneimage2' => {} }
        params[:images] = images
        subject.should contain_oneimage('oneimage1')
        subject.should contain_oneimage('oneimage2')
      end

      it 'when supplied a hash of entries with parameters should pass parameters to resources' do
        images = {
          'oneimage1' => {
            'ensure' => 'present',
            'description' => 'image 1',
          },
          'oneimage2' => {
            'ensure' => 'present',
            'type' => 'os',
          }
        }
        params[:images] = images
        subject.should contain_oneimage('oneimage1').with(images['oneimage1'])
      end
    end

    describe 'image_purge' do
      it 'should enable purging when enabled' do
        params[:image_purge] = true
        subject.should contain_resources('oneimage').with_purge(true)
      end
    end
  end
end
