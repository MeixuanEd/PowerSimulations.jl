using PowerSystems
using JuMP

include(string(homedir(),"/.julia/v0.6/PowerSystems/data/data_5bus.jl"))
sys5 = PowerSystem(nodes5, generators5, loads5_DA, branches5, nothing, 230.0, 1000.0)

m = Model()

pre = PowerSimulations.generationvariables(m, sys5.generators.renewable, sys5.time_periods)
test_curtailment = [d for d in sys5.generators.renewable if !isa(d, PowerSystems.RenewableFix)]
PowerSimulations.powerconstraints(m, pre, test_curtailment, sys5.time_periods)

true