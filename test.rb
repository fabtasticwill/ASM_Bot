require 'socket' 
require 'open3'

class SimpleIrcBot
  def initialize(server, port, channel)
    @channel = channel
    @socket = TCPSocket.open(server, port)
    say "NICK ASMBot"
    say "USER ASMbot 0 * ASMBot"
    say "JOIN ##{@channel}"
    say_to_chan "#{1.chr}ACTION is here to help#{1.chr}"
  end

  def say(msg)
    puts msg
    @socket.puts msg
  end

  def say_to_chan(msg)
    say "PRIVMSG ##{@channel} :#{msg}"
  end

  def run
    loopnum = 0
    until @socket.eof? do
      msg = @socket.gets
      puts msg
      loopnum +=1
      securenum =0
      if msg.match(/^PING :(.*)$/)
        say "PONG #{$~[1]}"
        next
      end

      if msg.match(/PRIVMSG ##{@channel} :(.*)$/)
        content = $~[1]
        if securenum != loopnum
          secure = true
        end
        
        if content.match("!admin") && secure
          temp = msg
          temp.split("!admin")[0]
          #temp.slice!("!admin")
          if msg.start_with?(":Fabtasticwill!")
            if content.match("exit")

              say_to_chan("#{1.chr}ACTION is exiting...#{1.chr}")
              say "EXIT"
              abort("Exiting")
            end
          else
            say_to_chan("I'm sorry Dave, I'm afraid I can't do that.");
          end
          #end
        end
       # if msg.match("71.6.55.146")
        #  say_to_chan("Whats up, rainfvr?")
       # end
        if content.match("-clrtmp") && secure
          File.delete("/media/fabtasticwill/4173DBF35F437ACD/ASM Bot/temp.s");
        end
        if content.match("-assem") &&secure
          command = "./a.out"
          system("gcc \"/media/fabtasticwill/4173DBF35F437ACD/ASM Bot/temp.s\"")
          out = Open3.popen3(command) { |stdin, stdout, stderr, wait_thr| stdout.read }
          say_to_chan (out)
        end
        if content.match("!") && secure
          msg.untaint
          msg.gsub!(/.*?(?=!)/im, "")
          msg.delete!('!')
          File.open("/media/fabtasticwill/4173DBF35F437ACD/ASM Bot/temp.s", 'a') { |file| file.write(msg) }
        end
      end
    end
  end
  def quit
    say "PART ##{@channel} :message"
    say 'QUIT'
  end
end

bot = SimpleIrcBot.new("irc.ubuntu.com", 6667, '#botwatcher')

trap("INT"){ bot.quit }

bot.run