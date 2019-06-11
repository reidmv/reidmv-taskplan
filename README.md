# taskplan


## Description

This module provides a task for running Puppet task plans by invoking Bolt on the target system.

This can be useful because it provides a shim into invoking task plans programatically via an API, since tasks can be invoked via an API. Therefore, if we have a task that can invoke a plan, we have a means of invoking a plan via the Puppet orchestrator API.

## Example Usage

```
bolt task run taskplan \
  --modulepath /example/modules \
  --nodes local://localhost \
  --params '{"plan":"taskplan::test","params":{"message":"Hello"},"arguments":{"modulepath":"/example/modules"}}'
```

### Plan-specific tailored taskplan task

To create a plan-specific tailored taskplan task, use something like the following:

```ruby
#!/opt/puppetlabs/puppet/bin/ruby
require 'json'

$params = {
  'params'    => JSON.parse(STDIN.read),
  'plan'      => 'example::myplan',
  'arguments' => [],
}

taskplanrb = File.join($params['params']['_installdir'], 'util', 'files', 'taskplan.rb')

load(taskplanrb)
```
