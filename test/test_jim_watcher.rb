require 'helper'

class TestJimWatcher < Test::Unit::TestCase
  
  def in_jimfile?(filename)
    i = 0
    File.new('Jimfile', "r").each do |line|
      if line.include?(filename)
        i += 1
      end
    end
    i
  end
  
  context "Jim::Watcher" do
    setup do
      root = File.dirname(__FILE__)
      @directories = [File.join(root, 'tmp', 'lib'), File.join(root, 'fixtures')]
      @bundler = Jim::Bundler.new(fixture('jimfile'), Jim::Index.new(@directories))
    end
    
    context "dependencies management" do
      
      setup do
        File.open('Jimfile', "wb") { |io| io.print fixture('jimfile') }
      end
      
      teardown do
        File.delete('Jimfile')
      end
      
      context "add_dependency" do
      
        should "add a new dependency into the Jimfile" do
          Jim::Watcher.add_dependency('app/controllers/users.js')
          assert_equal(in_jimfile?('app/controllers/users'), 1)
        end
      
        should "not add a new dependency into Jimfile if it already exists" do
          Jim::Watcher.add_dependency('myproject.js')
          assert_equal(in_jimfile?('myproject'), 1)
        end
      
      end
    
      context "remove_dependency" do
      
        should "remove a dependecy from the Jimfile" do
          Jim::Watcher.remove_dependency('myproject.js')
          assert_equal(in_jimfile?('myproject'), 0)
        end
      
      end
      
      context "remove_extension" do

        should "remove the .js extension of the filename" do
          filename = Jim::Watcher.remove_extension("app/controllers/users.js")
          assert_equal("app/controllers/users", filename)

          filename = Jim::Watcher.remove_extension("app/controllers.js/users.js")
          assert_equal("app/controllers.js/users", filename)
        end

      end
    end
  end
  
end
