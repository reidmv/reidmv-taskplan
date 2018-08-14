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

# The HOME environment variable is important when invoking Bolt. If HOME is not
# already set, set it.
if ENV['HOME'].nil?
  require 'etc'
  ENV['HOME'] = Etc.getpwuid.dir
end

# Bolt is expected on paths that may or may not be in the PATH variable. When
# invoking it, prefer the package, then the gem, then default to PATH.
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
