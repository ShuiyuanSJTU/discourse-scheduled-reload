# frozen_string_literal: true

# name: discourse-scheduled-reload
# about: reload unicourn every 6 hours without downtime
# version: 0.0.2
# authors: pangbo
# url: https://github.com/ShuiyuanSJTU/discourse-scheduled-reload
# required_version: 2.7.0

after_initialize do
  require_relative "app/jobs/scheduled/scheduled-reload.rb"
end
