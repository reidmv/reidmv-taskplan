#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'

# Parameters expected:
#   Hash
#     String            plan
#     Hash              params
#     Hash              arguments
#     Optional[Boolean] debug
$params = JSON.parse(STDIN.read)

$bolt = if File.exist? '/opt/puppetlabs/bin/bolt'
          '/opt/puppetlabs/bin/bolt' # package install
        elsif File.exist? '/opt/puppetlabs/puppet/bin/bolt'
          '/opt/puppetlabs/puppet/bin/bolt' # gem install into the agent
        else
          'bolt' # expect it on the PATH
        end

def main
  cmd = Array.new
  cmd << $bolt << 'plan' << 'run'
  cmd << $params['plan']
  cmd << '--params' << $params['params'].to_json
  cmd << '--format' << 'json'

  $params['arguments'].each do |key,val|
    case val
    when true
      cmd << "--#{key}"
    when false
      cmd << "--no-#{key}"
    else
      cmd << "--#{key}" << val
    end
  end

  if run_command(*cmd).success?
    exit 0
  else
    exit 1
  end
end

def run_command(*command)
  output, status = Open3.capture2e(*command)
  STDOUT.puts output
  status
end

main
