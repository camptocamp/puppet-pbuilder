require 'spec_helper'

describe 'pbuilder::cowbuilder' do
  let (:title) { 'moo' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      describe 'default parameters' do
        it { should compile.with_all_deps }

        it { is_expected.to contain_class('pbuilder::cowbuilder::common') }

        it do
          is_expected.to contain_file("/etc/pbuilder/moo/pbuilderrc").
            with_content(/MIRRORSITE=""/).
            with_content(/DISTRIBUTION="#{facts[:os]['distro']['codename']}"/).
            with_content(/ARCH="#{facts[:os]['architecture']}"/).
            with_content(/BASEPATH="\/var\/cache\/pbuilder\/base-moo\.cow"/).
            without_content(/BASETGZ=/)
        end
      end

      describe 'methodurl set' do
        let (:params) do
          {methodurl: 'http://ftp.debian.org/debian'}
        end

        it { should compile.with_all_deps }

        it do
          is_expected.to contain_file("/etc/pbuilder/moo/pbuilderrc").
            with_content(/MIRRORSITE="http:\/\/ftp.debian.org\/debian"/)
        end
      end
    end
  end
end
