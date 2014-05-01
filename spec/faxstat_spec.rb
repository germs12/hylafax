require 'spec_helper'

describe Hylafax::Faxstat do

  before do
    Hylafax.configuration = nil
    ENV['FAX_SENDFAX_PATH'] = '/path/to/somewhere'
    ENV['FAX_FAXSTAT_PATH'] = '/another/path'
  end

  describe 'hylafax running' do
    it 'checks the status of the HylaFAX scheduler' do
      fake_faxstat_response = "HylaFAX scheduler on dev.ameridoc.com: Running\r\n"
      Hylafax::Faxstat.any_instance.stub(:faxstat).and_return(fake_faxstat_response)

      Hylafax.faxstat.running?.should == true
    end
  end

  describe 'modem' do
    it 'checks the status of the Modem is running and idle' do
      fake_faxstat_response = "HylaFAX scheduler on teldev05.ct.ameridoc.com: Running\r\nModem ttyACM0 (+1.203.602.0291): Running and idle\r\n\nJID Pri S           Owner                                 MailAddr Number       Pages Dials     TTS Status\n9   127 D            root                   ifndef@gmail.com 2037691544    1:1   1:12         \r\n8   126 F           admin                           root@localhost 2039873397    0:1   0:12         Job aborted by request\r\n"
      Hylafax::Faxstat.any_instance.stub(:faxstat).and_return(fake_faxstat_response)

      Hylafax.faxstat.modem_idle?.should == true
      Hylafax.faxstat.modem_sending?.should == false
    end

    it 'checks the status of the Modem is waiting to come free' do
      fake_faxstat_response = "HylaFAX scheduler on teldev05.ct.ameridoc.com: Running\r\nModem ttyACM0 (+1.203.602.0291): Waiting for modem to come free\r\n\nJID Pri S           Owner                                 MailAddr Number       Pages Dials     TTS Status\n11  127 R            root                   ifndef@gmail.com 2037691544    0:1   0:12         \r\n\nJID Pri S           Owner                                 MailAddr Number       Pages Dials     TTS Status\n9   127 D            root                   ifndef@gmail.com 2037691544    1:1   1:12         \r\n10  127 D            root                   ifndef@gmail.com 2037691544    1:1   1:12         \r\n8   126 F           admin                           root@localhost 2039873397    0:1   0:12         Job aborted by request\r\n"
      Hylafax::Faxstat.any_instance.stub(:faxstat).and_return(fake_faxstat_response)

      Hylafax.faxstat.modem_idle?.should == false
      Hylafax.faxstat.modem_sending?.should == false
    end

    it 'checks the status of the Modem is Sending a job' do
      fake_faxstat_response = "HylaFAX scheduler on teldev05.ct.ameridoc.com: Running\r\nModem ttyACM0 (+1.203.602.0291): Sending job 10\r\n\nJID Pri S           Owner                                 MailAddr Number       Pages Dials     TTS Status\n10  127 R            root                   ifndef@gmail.com 2037691544    0:1   0:12         \r\n\nJID Pri S           Owner                                 MailAddr Number       Pages Dials     TTS Status\n9   127 D            root                   ifndef@gmail.com 2037691544    1:1   1:12         \r\n8   126 F           admin                           root@localhost 2039873397    0:1   0:12         Job aborted by request\r\n"
      Hylafax::Faxstat.any_instance.stub(:faxstat).and_return(fake_faxstat_response)

      Hylafax.faxstat.modem_idle?.should == false
      Hylafax.faxstat.modem_sending?.should == true
    end

    it 'checks the status of the Modem is waiting to come ready' do
      fake_faxstat_response = "HylaFAX scheduler on teldev05.ct.ameridoc.com: Running\r\nModem ttyACM0 (+1.203.602.0291): Waiting for modem to come ready\r\n\nJID Pri S           Owner                                 MailAddr Number       Pages Dials     TTS Status\n9   127 D            root                   ifndef@gmail.com 2037691544    1:1   1:12         \r\n10  127 D            root                   ifndef@gmail.com 2037691544    1:1   1:12         \r\n8   126 F           admin                           root@localhost 2039873397    0:1   0:12         Job aborted by request\r\n"
      Hylafax::Faxstat.any_instance.stub(:faxstat).and_return(fake_faxstat_response)

      Hylafax.faxstat.modem_idle?.should == false
      Hylafax.faxstat.modem_sending?.should == false
    end

  end

  describe 'jobs' do

    it 'checks the presence of a job that does not exist' do
      fake_faxstat_response = "HylaFAX scheduler on dev.ameridoc.com: Running\r\n\nJID  Pri S  Owner Number       Pages Dials     TTS Status\n2    127 W jthull 2037421719    0:0   0:12         \r\n"
      Hylafax::Faxstat.any_instance.stub(:faxstat).and_return(fake_faxstat_response)

      Hylafax.faxstat.job(19).should == nil
    end

    it 'checks the presence of a job that does exist' do
      fake_faxstat_response = "HylaFAX scheduler on dev.ameridoc.com: Running\r\n\nJID  Pri S  Owner Number       Pages Dials     TTS Status\n2    127 W jthull 2037421719    0:0   0:12         \r\n"
      Hylafax::Faxstat.any_instance.stub(:faxstat).and_return(fake_faxstat_response)

      Hylafax.faxstat.job(2).should_not == nil
    end

    it 'checks the status of 2 jobs' do
      fake_faxstat_response = "HylaFAX scheduler on jthullbery.dev.ameridoc.com: Running\r\n\nJID  Pri S  Owner Number       Pages Dials     TTS Status\n3    127 W jthull 2037421719    0:0   0:12         \r\n\nJID  Pri S  Owner Number       Pages Dials     TTS Status\n2    127 F jthull 2037421719    0:0   0:12         Kill time expired\r\n"
      Hylafax::Faxstat.any_instance.stub(:faxstat).and_return(fake_faxstat_response)


      Hylafax.faxstat.job(2)['S'].should == 'F'
      Hylafax.faxstat.job(3)['S'].should == 'W'
    end

  end
  
end