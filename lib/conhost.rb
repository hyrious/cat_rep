# coding: utf-8
# this file works as the console server

def Dir.tmpdir
  @_tmpdir ||= ENV['TEMP'].tr '\\', '/'
end

class << Graphics
  alias _update_conhost update
  def update
    cat_rep_i = File.join Dir.tmpdir, 'cat_rep.i'
    cat_rep_o = File.join Dir.tmpdir, 'cat_rep.o'
    cat_rep_stderr = File.join Dir.tmpdir, 'cat_rep.stderr'
    if File.exist? cat_rep_i
      text = File.read cat_rep_i
      begin
        ret = eval(text, TOPLEVEL_BINDING).inspect
        open cat_rep_o, 'w' do |f|
          f.write ret
          File.delete cat_rep_i
        end
      rescue Exception => e
        open cat_rep_o, 'w' do |f|
          f.write 'nil'
          File.delete cat_rep_i
        end
        ret = ["#{e.class}: #{e}"]
        e.backtrace.each do |c|
          break if c.start_with?(':1:')
          if parts = c.match(/^(?<file>.+):(?<line>\d+)(?::in `(?<code>.*)')?$/)
            next if parts[:file] == __FILE__
            cd = Regexp.escape(File.join(Dir.getwd, ''))
            file = parts[:file].sub(/^#{cd}/, '')
            code = parts[:code] && ": #{parts[:code]}"
            ret << "   #{file} #{parts[:line]}#{code}"
          else
            ret << "   #{c}"
          end
        end
        ret = ret.join "\n"
        open cat_rep_stderr, 'w' do |f|
          f.write ret
        end
      end
    end
    _update_conhost
  end
end

class << STDOUT
  alias _write write
  def write *args
    cat_rep_stdout = File.join Dir.tmpdir, 'cat_rep.stdout'
    open cat_rep_stdout, 'a' do |f|
      f.write *args
    end
    _write *args
  end
end

class << STDERR
  alias _write write
  def write *args
    cat_rep_stderr = File.join Dir.tmpdir, 'cat_rep.stderr'
    open cat_rep_stderr, 'a' do |f|
      f.write *args
    end
    _write *args
  end
end
