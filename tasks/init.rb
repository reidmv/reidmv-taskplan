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

def main
  cmd = Array.new
  cmd << 'bolt' << 'plan' << 'run'
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

  unless $params.has_key? 'env'
    $params['env'] = {}
  end

  unless $params['env'].has_key? 'HOME'
    $params['env'] = {
      'HOME' => '/root',
    }
  end

  if run_command($params['env'], *cmd).success?
    exit 0
  else
    exit 1
  end
end

def run_command(env, *command)
  output, status = Open3.capture2e(env, *command)
  STDOUT.puts output
  status
end

main
