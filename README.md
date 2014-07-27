# Ring SQA
  Discovers NLNOG Ring nodes by monitoring /etc/hosts with inotify. UDP pings
  each node periodically recording latency as microseconds in SQL database

  Currently 5 threads

  1. main thread, launches everything and finally gives control to Analyze class
  2. sender thread, sends queries and populates DB with new negative response row
  3. receiver thread, receives replies and updates DB with positive response
  4. responder thread, receives queries and sends replies
  5. inotify monitor thread

## Use
  - ring-sqad --help
  - ring-sqad --daemonize

## Todo
  - Get rid of Sequel+SQLite share Hash or Array instead?
