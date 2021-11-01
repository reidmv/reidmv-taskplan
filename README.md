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

The task `taskplan` is generic, and can run any plan, but because it permits the user to pass arbitrary command line flags to Bolt, it is effectively a privileged task.

As an alternative to permitting users to run the generic privileged task, a plan-specific tailored task, built on taskplan, can be created. 

To create a tailored plan-specific taskplan, use the following pattern.

tailored.json file:

```json
{
  "description": "Sample plan-specific tailored taskplan task",
  "parameters": {
    "my_plans_parameter": {
      "type": "String",
      "description": "The first parameter from the plan"
    },
    "my_plans_other_parameter": {
      "type": "Integer",
      "description": "Another parameter from the plan"
    }
  },
  "input_method": "stdin",
  "files": [
    "taskplan/tasks/init.rb"
  ]
}
```

tailored.rb file:

```ruby
#!/opt/puppetlabs/puppet/bin/ruby
require 'json'

$params = {
  'params' => JSON.parse(STDIN.read),
  'plan'   => 'example::myplan',
}

taskplanrb = File.join($params['params']['_installdir'], 'taskplan', 'tasks', 'init.rb')

load(taskplanrb)
```
