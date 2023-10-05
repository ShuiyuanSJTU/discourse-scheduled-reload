# frozen_string_literal: true

# https://github.com/discourse/docker_manager/blob/main/lib/docker_manager/upgrader.rb

module ::Jobs
    class ScheduleReload < ::Jobs::Scheduled
        every 3.hours
    
        def execute(args)
            Process.kill("USR2", unicorn_launcher_pid)
        end

        def pid_exists?(pid)
            Process.getpgid(pid)
          rescue Errno::ESRCH
            false
        end

        def unicorn_launcher_pid
            `ps aux | grep unicorn_launcher | grep -v sudo | grep -v grep | awk '{ print $2 }'`.strip.to_i
        end
        
        def unicorn_master_pid
            `ps aux | grep "unicorn master -E" | grep -v "grep" | awk '{print $2}'`.strip.to_i
        end
        
        def unicorn_workers(master_pid)
            `ps -f --ppid #{master_pid} | grep worker | awk '{ print $2 }'`.split("\n").map(&:to_i)
        end
        
        def local_web_url
            "http://127.0.0.1:#{ENV["UNICORN_PORT"] || 3000}/srv/status"
        end
        
    end
  end