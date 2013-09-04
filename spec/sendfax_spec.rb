require 'spec_helper'

describe Hylafax::Sendfax do

  before do
    Hylafax.configuration = nil
    ENV['FAX_SENDFAX_PATH'] = '/path/to/somewhere'
    ENV['FAX_SENDFAX_HOST'] = '0.0.0.0'
    ENV['FAX_FAXSTAT_PATH'] = '/another/path'
    ENV['FAX_FAXRM_PATH']   = '/final/path'
  end

  describe 'sending a fax' do

    it 'successfully sends a fax' do

      fake_sendfax_response = "request id is 19 (group id 29) for host 0.0.0.0 (1 file)\n"
      Hylafax::Sendfax.any_instance.stub(:sendfax).and_return(fake_sendfax_response)      

      tmp = Hylafax::Sendfax.new(document: '/tmp/cool.pdf')
      tmp.transmit.should == true
      tmp.request_id.should == 19
      tmp.group_id.should == 29

    end

  end

end
