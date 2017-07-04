require 'sketchup.rb'

module Gears
    def self.define_gear_dialog

    end
    def self.create_involute_gear(diametral_pitch, tooth_count, pressure_angle)
        model = Sketchup.active_model
        entities = model.active_entities

        # Calculate the required intermediary parameters
        @pitch_diameter = tooth_count / diametral_pitch
        @pitch_radius = @pitch_diameter / 2.0
        @base_circle_diameter = @pitch_diameter * Math.cos(pressure_angle * Math::PI / 180.0) 
        @base_circle_radius = @base_circle_diameter / 2.0
        @addendum = 1.0 / diametral_pitch
        @dedendum = Math::PI / (2.0 * diametral_pitch)
        @outside_diameter = @pitch_diameter + 2.0 * @addendum
        @outside_radius = @outside_diameter / 2.0
        @root_diameter = @pitch_diameter - 2.0 * @dedendum
        @root_radius = @root_diameter / 2.0
        @base_circle_circumference = Math::PI * @base_circle_diameter

        puts "bcr #{@base_circle_radius}, rr #{@root_radius}, or #{@outside_radius}"

        # create a circle
        @angle = 0.0
        points = Array.new
        while @angle < Math::PI * 2
            points.push([@root_radius * Math.sin(@angle), @root_radius * Math.cos(@angle), 0])

            @angle = @angle + Math::PI / 8
        end
        points.push([@base_circle_radius * Math.sin(0), @base_circle_radius * Math.cos(0), 0])

        #entities.add_edges(points)

        # now generate an involute tooth
        @base_angle = 0.0
        
        points = Array.new
        while (@base_angle < Math::PI * 2.0)
            puts "ba = #{@base_angle}"

            points.push([@root_radius * Math.cos(@base_angle), @root_radius * Math.sin(@base_angle), 0])

            @angle = 0.0
            while @angle < Math::PI / (2.0 * tooth_count)
                @involute_length = @base_circle_radius * @angle * 2.0

                #puts "#{@angle} involute_length = #{@involute_length}, base_circle_radius = #{@base_circle_radius}"
                @x = Math.cos(@angle + @base_angle) * @base_circle_radius + Math.sin(Math::PI / 2.0 - (@angle + @base_angle)) * @involute_length
                @y = Math.sin(@angle + @base_angle) * @base_circle_radius + Math.cos(Math::PI / 2.0 - (@angle + @base_angle)) * @involute_length

                if (Math.sqrt(@x * @x + @y * @y) > @outside_radius) then
                    @a = Math.atan2(@y, @x)

                    @x = Math.cos(@a) * @outside_radius
                    @y = Math.sin(@a) * @outside_radius
                end

                points.push([@x, @y, 0])
                
                @angle += (Math::PI / (2.0 * tooth_count)) / 16.0
            end  

            puts "#{@base_angle + @angle}"

            @base_angle += Math::PI / tooth_count

            puts "#{@base_angle - @angle}"
            while @angle > 0 
                @involute_length = @base_circle_radius * @angle * 2.0

                #puts "#{@angle} involute_length = #{@involute_length}, base_circle_radius = #{@base_circle_radius}"
                @x = Math.cos(@base_angle - @angle) * @base_circle_radius + Math.sin(Math::PI / 2.0 - (@base_angle - @angle)) * @involute_length
                @y = Math.sin(@base_angle - @angle) * @base_circle_radius + Math.cos(Math::PI / 2.0 - (@base_angle - @angle)) * @involute_length

                if (Math.sqrt(@x * @x + @y * @y) > @outside_radius) then
                    @a = Math.atan2(@y, @x)

                    @x = Math.cos(@a) * @outside_radius
                    @y = Math.sin(@a) * @outside_radius
                end

                points.push([@x, @y, 0])
                
                @angle -= (Math::PI / (2.0 * tooth_count)) / 16.0
            end  

            @angle = 0.0
            while @angle < Math::PI / tooth_count 
                points.push([@root_radius * Math.cos(@base_angle + @angle), @root_radius * Math.sin(@base_angle + @angle), 0])
                @angle += (Math::PI / (2.0 * tooth_count)) / 16.0
            end
            
            @base_angle += Math::PI / tooth_count
            
        end

        # Add the final connector to close the loop
        points.push([@root_radius * Math.cos(@base_angle), @root_radius * Math.sin(@base_angle), 0])

        entities.add_edges(points)
    end

    self.create_involute_gear 4.0, 20.0, 14.5
end