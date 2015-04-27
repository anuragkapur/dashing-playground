require 'net/http'
require 'json'

#this must exist on the server and be rw for root only - it is ignored by puppet
#config = YAML.load_file("/apps/dashing/config.yml")

# TODO: read key from a config file
api_key = 'FT-login-admin-1' #config["prod"]["aim_healthcheck"]["api_key"]

# TODO: read this from a config file
service_hostnames = ['login-service-eu-prod.herokuapp.com', 'login-service-us-prod.herokuapp.com']

SCHEDULER.every '10s', first_in: 0 do |job|
  service_hostnames.each { |service_hostname|
    http = Net::HTTP.new(service_hostname, 443)
    http.use_ssl = true
    response = http.request(Net::HTTP::Get.new("/admin/healthcheck?ft_auth_key=#{api_key}"))

    if response.code == '200'
      send_event(service_hostname, { status: 'background:olivedrab'})
    else
      send_event(service_hostname, { status: 'background:crimson'})
    end
  }
end
