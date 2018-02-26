
require 'openstudio'
require 'lib/baseline_model'
require 'json'

model = BaselineModel.new
  
	model.add_standards( JSON.parse('{
  "schedules": [
    {
        "name": "Medium Office Bldg Swh",
        "category": "Service Water Heating",
        "units": null,
        "day_types": "Default|SmrDsn",
        "start_date": "2014-01-01T00:00:00+00:00",
        "end_date": "2014-12-31T00:00:00+00:00",
        "type": "Hourly",
        "notes": "From DOE Reference Buildings ",
        "values": [
          0.05, 0.05, 0.05, 0.05, 0.05, 0.08, 0.07, 0.19, 0.35, 0.38, 0.39, 0.47, 0.57, 0.54, 0.34, 0.33, 0.44, 0.26, 0.21, 0.15, 0.17, 0.08, 0.05, 0.05
        ]
      },
      {
        "name": "Medium Office Bldg Swh",
        "category": "Service Water Heating",
        "units": null,
        "day_types": "Sun",
        "start_date": "2014-01-01T00:00:00+00:00",
        "end_date": "2014-12-31T00:00:00+00:00",
        "type": "Hourly",
        "notes": "From DOE Reference Buildings ",
        "values": [
          0.04, 0.04, 0.04, 0.04, 0.04, 0.07, 0.04, 0.04, 0.04, 0.04, 0.04, 0.06, 0.06, 0.09, 0.06, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.07, 0.04, 0.04
        ]
      },
      {
        "name": "Medium Office Bldg Swh",
        "category": "Service Water Heating",
        "units": null,
        "day_types": "WntrDsn|Sat",
        "start_date": "2014-01-01T00:00:00+00:00",
        "end_date": "2014-12-31T00:00:00+00:00",
        "type": "Hourly",
        "notes": "From DOE Reference Buildings ",
        "values": [
          0.05, 0.05, 0.05, 0.05, 0.05, 0.08, 0.07, 0.11, 0.15, 0.21, 0.19, 0.23, 0.2, 0.19, 0.15, 0.13, 0.14, 0.07, 0.07, 0.07, 0.07, 0.09, 0.05, 0.05
        ]
      }
    ]
  }') )

#make a 2 story, 100m X 50m, 10 zone core/perimeter building
model.add_geometry({"length" => 100,
              "width" => 50,
              "num_floors" => 2,
              "floor_to_floor_height" => 4,
              "plenum_height" => 1,
              "perimeter_zone_depth" => 3})

#add windows at a 40% window-to-wall ratio
model.add_windows({"wwr" => 0.4,
                  "offset" => 1,
                  "application_type" => "Above Floor"})
        
#add ASHRAE System type 01, PTAC, Residential
model.add_hvac({"ashrae_sys_num" => '01'})

#add thermostats
model.add_thermostats({"heating_setpoint" => 24,
                      "cooling_setpoint" => 28})
              
#assign constructions from a local library to the walls/windows/etc. in the model
model.set_constructions()

#set whole building space type; simplified 90.1-2004 Large Office Whole Building
model.set_space_type()  

#add design days to the model (Chicago)
model.add_design_days()

# make a shading surface
vertices = OpenStudio::Point3dVector.new
vertices << OpenStudio::Point3d.new(0,0,0)
vertices << OpenStudio::Point3d.new(10,0,0)
vertices << OpenStudio::Point3d.new(10,4,0)
vertices << OpenStudio::Point3d.new(0,4,0)
rotation = OpenStudio::createRotation(OpenStudio::Vector3d.new(1,0,0), OpenStudio::degToRad(30))
vertices = rotation*vertices

group = OpenStudio::Model::ShadingSurfaceGroup.new(model)
group.setXOrigin(20)
group.setYOrigin(10)
group.setZOrigin(8)

shade = OpenStudio::Model::ShadingSurface.new(vertices, model)
shade.setShadingSurfaceGroup(group)

# create the panel
panel = OpenStudio::Model::GeneratorPhotovoltaic::simple(model)
panel.setSurface(shade)

# create the inverter
inverter = OpenStudio::Model::ElectricLoadCenterInverterSimple.new(model)

# create the distribution system
elcd = OpenStudio::Model::ElectricLoadCenterDistribution.new(model)
elcd.addGenerator(panel)
elcd.setInverter(inverter)

# output variables
panel.outputVariableNames.each do |var|
  OpenStudio::Model::OutputVariable.new(var, model)
end
inverter.outputVariableNames.each do |var|
  OpenStudio::Model::OutputVariable.new(var, model)
end
elcd.outputVariableNames.each do |var|
  OpenStudio::Model::OutputVariable.new(var, model)
end
      
#save the OpenStudio model (.osm)
model.save_openstudio_osm({"osm_save_directory" => Dir.pwd, "osm_name" => "out.osm"})
