# taskplan


## Description

This module provides a task for running Puppet task plans by invoking Bolt on the target system.

## Example Usage

```
bolt task run taskplan \
  --modulepath /example/modules \
  --nodes local://localhost \
  --params '{"plan":"taskplan::test","params":{"message":"Hello"},"arguments":{"modulepath":"/example/modules"}}'
```
