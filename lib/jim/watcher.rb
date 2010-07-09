module Jim
  class Watcher
    
    def self.watch(to)
      @@to = to
      
      require 'fssm'
      
      puts "*** Jim is now watching for JS updates..."
      
      system "jim bundle #{to}"
      
      FSSM.monitor(Dir.pwd, ['**/*.js', 'Jimfile']) do
        update do |base, relative|
          unless relative.include?('bundled.js')
            puts "*** Update #{relative}"
            system "jim bundle #{Jim::Watcher.to}"
          end
        end

        create do |base, relative|
          unless relative.include?('bundled.js')
            puts "*** Create #{relative}"
            Jim::Watcher.add_dependency(relative)
            system "jim bundle #{Jim::Watcher.to}"
          end
        end

        delete do |base, relative|
          puts "*** Delete #{relative}"   
          Jim::Watcher.remove_dependency(relative)
          system "jim bundle #{Jim::Watcher.to}"
        end
      end
    end
    
    def self.to
      @@to
    end
    
    def self.add_dependency(filename)
      filename = remove_extension(filename)
      
      already_present = false
      File.new('Jimfile', "r").each do |line|
        if line.include?(filename)
          already_present = true
          break
        end
      end
      
      unless already_present
        File.open('Jimfile', 'a') {|f| f.write("\n#{filename}") }
      end
    end
    
    def self.remove_dependency(filename)
      filename = remove_extension(filename)
      
      content = ""
      File.new('Jimfile', "r").each do |line|
        content << line unless line.include?(filename)
      end
      
      File.open('Jimfile', "wb") { |io| io.print content }
    end

    def self.remove_extension(filename)
      filename[0, filename.rindex('.js')]
    end

  end
end