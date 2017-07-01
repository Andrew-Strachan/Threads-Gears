require "sketchup.rb"

module Threads
 def self.define_thread_dialog
     # show the dialog to define a thread
     dialog = UI::HtmlDialog.new(
         {
             :dialog_title => "Define Thread Parameters",
             :preferences_key => "thread.plugin",
             :scrollable => true,
             :resizable => true,
             :width => 300,
             :height => 500,
             :left => 100,
             :top => 100,
             :min_width => 150,
             :min_height => 250,
             :style => UI::HtmlDialog::STYLE_DIALOG
         }
     )
     dialog.add_action_callback("execute") { |action_context,shaft_radius,shaft_length,thread_radius,thread_pitch|
        puts "Create thread now"
        self.generate_screw_thread 60.0, 200.0, 20.0, 50.0, 5.0, 25.0

        dialog.close();        
     }
     dialog.add_action_callback("cancel") { |action_context|
        puts "Cancelling"

        dialog.close();
     }     
     dialog.set_file(File.join(File.dirname(__FILE__), 'thread_definition.html'))

     #dialog.show
     self.generate_screw_thread 30.0/25.4, 50.0/25.4, 20.0/25.4, 16.0/25.4, 2.0/25.4, 8.0/25.4, true, false
 end

 def self.generate_screw_thread(shaft_radius, shaft_length,thread_radius,thread_pitch, outer_thread_thickness, inner_thread_thickness, taper_start, taper_end)
    model = Sketchup.active_model
    entities = model.active_entities

    # Create the 4 points for each step of the thread in each iteration
    # Offset everything from the centreline of the thread.
    # This will enable us to transition the thread more easily for instance
    # with respect to fading in or out of the thread
    @angle = 0.0
    @mesh = Geom::PolygonMesh.new
    @number_of_segments = 36.0
    @z = 0.0
    @segment = 0
    @current_shaft_radius = shaft_radius
    @current_thread_radius = taper_start ? shaft_radius : (shaft_radius + thread_radius)
    @segments = 0
    @current_outer_thread_thickness_offset = taper_start ? 0.0 : (outer_thread_thickness / 2.0)
    @current_shaft_thread_thickness_offset = taper_start ? 0.0 : ((thread_pitch - outer_thread_thickness - inner_thread_thickness) / 2.0)
    @point_indexes = []
    while @z.round(4) <= (shaft_length - (@current_outer_thread_thickness_offset + @current_shaft_thread_thickness_offset).round(4))
        #puts "Z = #{@z}, angle = #{@angle}, shaft radius = #{@current_shaft_radius}, thread radius = #{@current_thread_radius}, thread_offset = #{@current_outer_thread_thickness_offset}, shaft_offset = #{@current_shaft_thread_thickness_offset}"

        @point_indexes.push(@mesh.add_point([@current_shaft_radius * Math.sin(@angle), @current_shaft_radius * Math.cos(@angle), @z - @current_shaft_thread_thickness_offset]))
        @point_indexes.push(@mesh.add_point([@current_thread_radius * Math.sin(@angle), @current_thread_radius * Math.cos(@angle), @z - @current_outer_thread_thickness_offset]))
        @point_indexes.push(@mesh.add_point([@current_thread_radius * Math.sin(@angle), @current_thread_radius * Math.cos(@angle), @z + @current_outer_thread_thickness_offset]))
        @point_indexes.push(@mesh.add_point([@current_shaft_radius * Math.sin(@angle), @current_shaft_radius * Math.cos(@angle), @z + @current_shaft_thread_thickness_offset]))

        #puts "#{@segment} :: [#{@current_shaft_radius * Math.sin(@angle)}, #{@current_shaft_radius * Math.cos(@angle)}, #{@z - @current_shaft_thread_thickness_offset}])"
        #@segment = @segment + 1
        #puts "#{@segment} :: [#{@current_thread_radius * Math.sin(@angle)}, #{@current_thread_radius * Math.cos(@angle)}, #{@z - @current_outer_thread_thickness_offset}])"
        #@segment = @segment + 1
        #puts "#{@segment} :: [#{@current_thread_radius * Math.sin(@angle)}, #{@current_thread_radius * Math.cos(@angle)}, #{@z + @current_outer_thread_thickness_offset}])"
        #@segment = @segment + 1
        #puts "#{@segment} :: [#{@current_shaft_radius * Math.sin(@angle)}, #{@current_shaft_radius * Math.cos(@angle)}, #{@z + @current_shaft_thread_thickness_offset}])"
        #@segment = @segment + 1

        @angle = @angle + 2.0 * Math::PI / @number_of_segments

        @z = @z + thread_pitch / @number_of_segments

        if @angle > 2.0 * Math::PI then
            @angle = @angle - 2.0 * Math::PI
        end

        if @segments < @number_of_segments / 4.0 && taper_start then
            @divisor = @number_of_segments / 4.0
            @current_outer_thread_thickness_offset = @current_outer_thread_thickness_offset + (outer_thread_thickness / 2.0) / @divisor
            @current_shaft_thread_thickness_offset = @current_shaft_thread_thickness_offset + ((thread_pitch - outer_thread_thickness - inner_thread_thickness) / 2.0) / @divisor

            @current_thread_radius = @current_thread_radius + thread_radius / @divisor
        end
        if @z >= shaft_length - (thread_pitch / 4.0) && taper_end then
            @end_divisor = @number_of_segments / 4.0
            @current_outer_thread_thickness_offset = @current_outer_thread_thickness_offset - (outer_thread_thickness / 2.0) / @end_divisor
            @current_shaft_thread_thickness_offset = @current_shaft_thread_thickness_offset - ((thread_pitch - outer_thread_thickness - inner_thread_thickness) / 2.0) / @end_divisor

            if @current_outer_thread_thickness_offset < 0.0 then
                @current_outer_thread_thickness_offset = 0.0
            end

            if @current_shaft_thread_thickness_offset < 0.0 then
                @current_shaft_thread_thickness_offset = 0.0
            end

            @current_thread_radius = @current_thread_radius - thread_radius / @end_divisor
        end

        @segments = @segments + 1

        #puts "mesh_points = #{@mesh.count_points}, index_points = #{@point_indexes.count}"
    end

    #puts 'Completed point generation'

    # Now we've constructed the mesh points we need to join them up
    @segmentCount = 0
    while @segmentCount < @segments - 2
        @segment_index = 1

        if (@segmentCount == 0) then
            unless taper_start then
                @mesh.add_polygon @point_indexes[0], @point_indexes[3], @point_indexes[1]
                #puts "#{@segmentCount} : #{@point_indexes[0]}, #{@point_indexes[3]}, #{@point_indexes[1]}"

                @mesh.add_polygon @point_indexes[0], @point_indexes[1], @point_indexes[4]
                #puts "#{@segmentCount} : #{@point_indexes[0]}, #{@point_indexes[1]}, #{@point_indexes[4]}"

                @mesh.add_polygon @point_indexes[0], @point_indexes[4], @point_indexes[3]
                #puts "#{@segmentCount} : #{@point_indexes[0]}, #{@point_indexes[4]}, #{@point_indexes[3]}"

                @mesh.add_polygon @point_indexes[3], @point_indexes[2], @point_indexes[1]
                #puts "#{@segmentCount} : #{@point_indexes[3]}, #{@point_indexes[2]}, #{@point_indexes[1]}"
            end

            @mesh.add_polygon @point_indexes[1], @point_indexes[5], @point_indexes[4]
            #puts "#{@segmentCount} : #{@point_indexes[1]}, #{@point_indexes[5]}, #{@point_indexes[4]}"
        end

        while @segment_index < ((@segmentCount == @segments - 2) ? 5 : 7)
            @mesh.add_polygon @point_indexes[@segmentCount * 4 + @segment_index], @point_indexes[@segmentCount * 4 + 1 + @segment_index], @point_indexes[(@segmentCount + 1) * 4 + @segment_index]

            #puts "#{@segmentCount} : #{@point_indexes[@segmentCount * 4 + @segment_index]}, #{@point_indexes[@segmentCount * 4 + 1 + @segment_index]}, #{@point_indexes[(@segmentCount + 1) * 4 + @segment_index]}"

            @mesh.add_polygon @point_indexes[@segmentCount * 4 + 1 + @segment_index], @point_indexes[(@segmentCount + 1) * 4 + @segment_index + 1], @point_indexes[(@segmentCount + 1) * 4 + @segment_index]
            
            #puts "#{@segmentCount} : #{@point_indexes[@segmentCount * 4 + 1 + @segment_index]}, #{@point_indexes[(@segmentCount + 1) * 4 + @segment_index + 1]}, #{@point_indexes[(@segmentCount + 1) * 4 + @segment_index]}"

            @segment_index = @segment_index + 1
        end

        # Join this thread to the next iteration if we're not on the last thread
        #if (@segmentCount < @segment - @number_of_segments) then
        #    @mesh.add_polygon  @segmentCount * 4, (@segmentCount * 4) + 1 , (@segmentCount + @number_of_segments - 3) * 4
        #end

        @segmentCount = @segmentCount + 1
    end

    unless taper_end then
        # We need to close the thread - undo the last segment increments so we have the right indexes
        @segmentCount -= 1
        @segment_index -= 1

        #puts "#{@segmentCount} : #{@point_indexes[(@segmentCount + 1) * 4 + @segment_index + 1]}, #{@point_indexes[@segmentCount * 4 + @segment_index + 1]}, #{@point_indexes[@segmentCount * 4 + 2 + @segment_index]}"
        @mesh.add_polygon @point_indexes[(@segmentCount + 1) * 4 + @segment_index + 1], @point_indexes[@segmentCount * 4 + @segment_index + 1], @point_indexes[@segmentCount * 4 + 2 + @segment_index]
        
        #puts "#{@segmentCount} : #{@point_indexes[(@segmentCount + 1) * 4 + @segment_index + 1]}, #{@point_indexes[(@segmentCount + 1) * 4 - 1 + @segment_index]}, #{@point_indexes[(@segmentCount + 1) * 4 + @segment_index]}"
        @mesh.add_polygon @point_indexes[(@segmentCount + 1) * 4 + @segment_index + 1], @point_indexes[(@segmentCount + 1) * 4 - 1 + @segment_index], @point_indexes[(@segmentCount + 1) * 4 + @segment_index]
        
        #puts "#{@segmentCount} : #{@point_indexes[(@segmentCount + 1) * 4 + @segment_index + 1]}, #{@point_indexes[(@segmentCount + 1) * 4 + @segment_index - 2]}, #{@point_indexes[(@segmentCount  + 1) * 4 - 1 + @segment_index]}"
        @mesh.add_polygon @point_indexes[(@segmentCount + 1) * 4 + @segment_index + 1], @point_indexes[(@segmentCount + 1) * 4 + @segment_index - 2], @point_indexes[(@segmentCount  + 1) * 4 - 1 + @segment_index]
        
    end

    # Create a new group that we will populate with the mesh.
    @group = Sketchup.active_model.entities.add_group
    @smooth_flags = Geom::PolygonMesh::NO_SMOOTH_OR_HIDE
    @group.entities.add_faces_from_mesh(@mesh, @smooth_flags)    

 end

end