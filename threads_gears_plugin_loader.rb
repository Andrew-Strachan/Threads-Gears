require 'sketchup.rb'
require 'extensions.rb'

# Load plugin as extension (so that user can disable it)
module AKS
    module ThreadsGears 
        threads_gears_plugin_loader = SketchupExtension.new 'Threads/Gears Plugin Loader',
        File.join(File.dirname(__FILE__), 'threads_gears_plugin', 'threads_gears_plugin.rb')
        threads_gears_plugin_loader.copyright= "Copyright 2017 by Andrew Strachan"
        threads_gears_plugin_loader.creator= "Andrew Strachan"
        threads_gears_plugin_loader.version = "0.1"
        threads_gears_plugin_loader.description = "Creates thread and gear shapes in sketchup."
        Sketchup.register_extension threads_gears_plugin_loader, true
    end
end

# load 'C:/Users/strac/Source/Repos/threads-gears/threads_gears_plugin_loader.rb'