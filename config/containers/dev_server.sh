#!/usr/bin/env bash
exec bundle exec unicorn -p $PORT -c config/containers/unicorn.rb
