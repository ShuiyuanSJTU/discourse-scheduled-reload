# frozen_string_literal: true

# https://github.com/discourse/docker_manager/blob/main/lib/docker_manager/upgrader.rb

module ::Jobs
    class ScheduleReload < ::Jobs::Scheduled
        every 6.hours
    
        def execute(args)
            fork do
                Process.setsid
                reload_unicorn(unicorn_launcher_pid)
            end
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
        
        def reload_unicorn(launcher_pid)
            original_master_pid = unicorn_master_pid
            Process.kill("USR2", launcher_pid)
        
            iterations = 0
            while pid_exists?(original_master_pid)
            iterations += 1
            break if iterations >= 60
            sleep 2
            end
        
            iterations = 0
            while `curl -s #{local_web_url}` != "ok"
            iterations += 1
            break if iterations >= 60
            sleep 2
            end
        end
    end
  end