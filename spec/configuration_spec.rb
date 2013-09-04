require 'spec_helper'

describe Hylafax::Configuration do
  describe 'when no sendfax_path is specified' do
    before do
      ENV['FAX_SENDFAX_PATH'] = '/path/to/no/where'
      Hylafax.configuration = nil
      Hylafax.configure do |config|
      end
    end

    it 'defaults to ENV["FAX_SENDFAX_PATH"]' do
      Hylafax.configuration.sendfax_path.should == '/path/to/no/where'
    end
  end

  describe 'when sendfax_path is specified' do
    before do
      Hylafax.configure do |config|
        config.sendfax_path = '/path/to/some/where'
      end
    end

    it 'is used instead of the ENV variable' do
      Hylafax.configuration.sendfax_path.should == '/path/to/some/where'
    end
  end

  describe 'when a hash is passed in from an old yaml instead' do
    it 'uses those values' do
      Hylafax.configuration = Hylafax::Configuration.new({'sendfax_path' => '/path/to/any/where' })
      Hylafax.configuration.sendfax_path.should == '/path/to/any/where'
    end

    it 'should set the cover sheet' do
      Hylafax.configuration = Hylafax::Configuration.new({ 'sendfax_path' => '/path/to/any/where', 'cover_sheet' => true })
      Hylafax.configuration.cover_sheet.should == true
    end

    it 'should set the signalling rate' do
      Hylafax.configuration = Hylafax::Configuration.new({ 'sendfax_path' => '/path/to/any/where', 'speed' => 9600 })
      Hylafax.configuration.speed.should == 9600
    end
  end
end
