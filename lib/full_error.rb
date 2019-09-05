# coding: utf-8
#==============================================================================
# FullError.rb
#==============================================================================
# @plugindesc Show full backtrace when error occurs.
# @author hyrious
#
# @help This plugin does not provide plugin commands.

# @mod rgss_main
alias _full_error_rgss_main rgss_main
def rgss_main(*args, &blk)
  _full_error_rgss_main(*args, &blk)
rescue Exception => e
  puts "#{e.class}: #{e.message}"
  e.backtrace.each do |c|
    break if c.start_with?(':1:')
    if parts = c.match(/^(?<file>.+):(?<line>\d+)(?::in `(?<code>.*)')?$/)
      next if parts[:file] == __FILE__
      cd = Regexp.escape(File.join(Dir.getwd, ''))
      file = parts[:file].sub(/^#{cd}/, '')
      if inner = file.match(/^\{(?<rgss>\d+)\}$/)
        id = inner[:rgss].to_i
        file = "[#{$RGSS_SCRIPTS[id][1]}]"
      end
      code = parts[:code] && ": #{parts[:code]}"
      puts "   #{file} #{parts[:line]}#{code}"
    else
      puts "   #{c}"
    end
  end
  rgss_stop
end
