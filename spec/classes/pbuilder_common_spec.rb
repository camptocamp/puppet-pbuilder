require 'spec_helper'

describe 'pbuilder::common' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { should compile.with_all_deps }

      it { is_expected.to contain_package('pbuilder') }

      it { is_expected.to contain_group('pbuilder') }
    end
  end
end
