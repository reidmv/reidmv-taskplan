#!/opt/puppetlabs/puppet/bin/ruby
# rubocop:disable Style/GlobalVars, Style/SafeNavigation
require 'json'
require 'open3'
require 'etc'

# Parameters expected:
#   Hash
#     String            plan
#     Hash              params
#     Hash              arguments
#     Optional[Boolean] debug
$params ||= JSON.parse(STDIN.read)

# The HOME environment variable is important when invoking Bolt. If HOME is not
# already set, set it.
ENV['HOME'] ||= Etc.getpwuid.dir

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
  cmd = []
  cmd << $bolt << 'plan' << 'run'
  cmd << $params['plan']
  cmd << '--params' << $params['params'].to_json
  cmd << '--format' << 'json'

  if $params['arguments']
    $params['arguments'].each do |key, val|
      case val
      when true
        cmd << "--#{key}"
      when false
        cmd << "--no-#{key}"
      else
        cmd << "--#{key}" << val
      end
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
