module Hylafax
  class Faxstat

    attr_accessor :response, :jobs, :running, :modem

    def initialize(options={})
      configure_from_env
      @jobs = {}
      @modem = {running: false, ready: false, free: false, sending: false, response: nil, name: nil, number: nil}
      raise Hylafax::ConfigError if Hylafax.configuration.faxstat_path.nil?
    end

    def running?
      update_status
      @running
    end

    def modem_idle?
      update_status
      @modem[:free]
    end

    def modem_sending?
      update_status
      @modem[:sending]
    end

    def job( job_id )
      update_status
      @jobs[job_id]
    end

    private
    def update_status
      @response = faxstat
      parse_response
    end

    def faxstat
      `#{Hylafax.configuration.faxstat_path} -sdl`
    end

    def parse_response
      # Clean string
      tmp = @response.gsub(/[\r]/, '').split("\n").reject{|x| x.empty?}
      # binding.pry

      # Set running value and remove
      @running = tmp[0].split(":").last.include?("Running")
      tmp = tmp[(1..-1)]

      unless tmp.empty?
        # Remove duplicate headers      
        header = tmp.select{|x| x.include?("JID")}.first
        tmp = [header] + tmp.reject!{|x| x.include?('JID')}
         
        # Handle the Modem string
        # Then remove it
        if tmp[1][(0...5)].eql?("Modem")
          @modem[:response] = tmp[1]
          parse_modem
          tmp.reject!{|a| a[(0...5)].eql?("Modem")}
        end

        # binding.pry
        
        tmp_jobs = tmp.each{|job| job.split("\n")}.delete_if{|str| str.empty? || str.eql?("\n")}
        unless tmp_jobs.empty?
          key = tmp_jobs[0].split(" ")
          tmp_jobs[(1..-1)].each do |job|
            value = job.split(" ")
            @jobs[value[0].to_i] = Hash[key.zip value]
          end
        end
      end
    end

    def parse_modem
      resp = @modem[:response]
      resp = resp.split(" ")
      @modem[:name] = resp[1]
      @modem[:number] = resp[2]
      @modem[:sending] = resp[3].eql?("Sending")
      @modem[:running] = @modem[:sending].eql?(true)
      @modem[:ready] = (!@modem[:sending].eql?(true))
      @modem[:free] = resp[3].eql?("Free") || resp[3].eql?("Running")
    end

    def configure_from_env
      if defined?(Rails) && File.exists?(file=Rails.root.join('config/fax.yml'))
        yaml_config = YAML.load_file file
        Hylafax.configuration = Hylafax::Configuration.new yaml_config[Rails.env]
      end

      Hylafax.configuration ||= Hylafax::Configuration.new
    end
  end
end
