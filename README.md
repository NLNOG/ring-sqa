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

### Code Quality Improvements (RuboCop Findings)

#### Critical Security Issues
  - Replace Kernel#open with safer alternatives
  - Remove or secure any eval usage

#### High Priority Code Quality
  - Refactor long methods (21 instances)
  - Reduce method complexity (13 instances)
  - Fix complex control flow (2 instances)
  - Replace Exception rescue with StandardError

#### Style and Layout
  - Add missing class documentation (24 instances)
  - Fix indentation and spacing issues
  - Standardize method parameter formatting
  - Improve hash alignment and syntax
  - Add frozen string literal comments

#### Code Smells
  - Remove useless assignments
  - Fix unused block arguments
  - Remove redundant begin blocks
  - Add proper guard clauses
