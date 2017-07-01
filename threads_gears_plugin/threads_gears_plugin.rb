=begin
Copyright 2017, Andrew Strachan
All Rights Reserved
THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
License: MIT
Author: Andrew Strachan
Name: Threads/Gears Plugin
Version: 0.1
SU Version: 2017
Date: 2017-06-11
Description: 
Usage: 
History:
 1.000 YYYY-MM-DD Description of changes
=end

require 'sketchup.rb'
require_relative 'threads.rb'
require_relative 'gears.rb'

# Main code (start module name with capital letter)
module Threads_gears_module
 def self.create_thread
# do something...
    Threads.define_thread_dialog();
 end
 def self.create_gear
    Gears.create_gear();
 end

# Create menu items
#unless file_loaded?(__FILE__)
 mymenu = UI.menu('Tools').add_submenu('Threads/Gears')
 mymenu.add_item('Create Thread') {Threads_gears_module::create_thread}
 mymenu.add_item('Create Gear') {Threads_gears_module::create_gear}
 file_loaded(__FILE__)
#end

end