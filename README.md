# Ring SQA
  Discovers NLNOG Ring nodes by monitoring /etc/hosts with inotify. UDP pings
  each node periodically recording latency as microseconds in SQL database

  Currently 4 threads

  1. main thread, launches everything and finally gives control to Analyze class
  2. querier thread, sends queries and waits for responses, populates database
  3. responder thread, waits for queries and echoes them back
  4. inotify monitor thread

## Use
  ring-sqad --help
  ring-sqad --daemonize

## Todo
  1. Querier loop should sleep dynamically between nodes to spread CPU/network demand
  2. Analyzer class should actually do something (use average of numbers before median as norm, if last Y measurements are Z times above norm (or more than X standard deviations?) raise alarm?
