
require 'openstudio'
require 'lib/baseline_model'

model = BaselineModel.new

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
        
#add ASHRAE System type 07, VAV w/ Reheat
model.add_hvac({"ashrae_sys_num" => '07'})

plant = OpenStudio::Model::PlantLoop.new(model)
plant.setName('Economizing Plant')

sizingPlant = plant.sizingPlant()
sizingPlant.setLoopType('Condenser')
sizingPlant.setDesignLoopExitTemperature(26.0);
sizingPlant.setLoopDesignTemperatureDifference(5.6);

outletNode = plant.supplyOutletNode()
inletNode = plant.supplyInletNode()

s = OpenStudio::Model::ScheduleConstant.new(model)
s.setValue(26.0)
spm = OpenStudio::Model::SetpointManagerScheduled.new(model,s)
spm.addToNode(outletNode)                  

pump = OpenStudio::Model::PumpVariableSpeed.new(model)
pump.addToNode(inletNode)

tower = OpenStudio::Model::CoolingTowerVariableSpeed.new(model)
plant.addSupplyBranchForComponent(tower)

hx = OpenStudio::Model::HeatExchangerFluidToFluid.new(model)
plant.addDemandBranchForComponent(hx)

chiller = model.getChillerElectricEIRs.first
hx.addToNode(chiller.supplyInletModelObject.get.to_Node.get)


#add thermostats
model.add_thermostats({"heating_setpoint" => 24,
                      "cooling_setpoint" => 28})
              
#assign constructions from a local library to the walls/windows/etc. in the model
model.set_constructions()

#set whole building space type; simplified 90.1-2004 Large Office Whole Building
model.set_space_type()  

#add design days to the model (Chicago)
model.add_design_days()
       
#save the OpenStudio model (.osm)
model.save_openstudio_osm({"osm_save_directory" => Dir.pwd,
                           "osm_name" => "out.osm"})
                           
