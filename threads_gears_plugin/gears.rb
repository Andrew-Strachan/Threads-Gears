require 'sketchup.rb'

module Gears
    def self.define_gear_dialog

    end
    def self.create_gear
        model = Sketchup.active_model
        entities = model.active_entities

        # create a circle
        angle = 0
        points = Array.new
        while angle < Math::PI * 2
            points.push([60 * Math.sin(angle), 60 * Math.cos(angle), 0])

            angle = angle + Math::PI / 8
        end
        points.push([60 * Math.sin(0), 60 * Math.cos(0), 0])

        entities.add_edges(points)
    end
end