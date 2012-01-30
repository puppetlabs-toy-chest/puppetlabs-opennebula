#!/usr/bin/env rspec

require 'spec_helper'

describe 'opennebula::node', :type => :class do
  # Set it to Debian, as this is supported
  let(:facts) do
    { :operatingsystem => "debian" }
  end

  describe 'when you adjust a parameter' do
    let(:params) do
      {
        :controller    => "myonecontroller",
        :node_package  => "opennebulapkg",
      }
    end

    describe 'node_package' do
      it 'should change the package that gets installed' do
        params[:node_package] = "nodepackage"
        subject.should contain_package('nodepackage')
      end
    end

    describe 'controller' do
      pending 'should change the title to import for ssh_authorized_keys' do
      end
    end
  end
end
