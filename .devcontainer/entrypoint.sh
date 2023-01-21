#!/bin/bash
set -e

# remove potentially existing server.pid for rails
rm -f /myapp/tmp/pids/server.pid

# exec container's main process
exec "$@"