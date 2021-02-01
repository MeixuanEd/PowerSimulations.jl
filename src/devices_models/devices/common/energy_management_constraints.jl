@doc raw"""
Constructs constraint energy target data, and variable
# Constraints
`` varenergy[name, end] + varslack[name, end] >= paramenergytarget[name, end] ``
# LaTeX
`` x^{energy}_t + x^{slack}_t >= x^{energy}_{target} \text{ for } t = end ``
# Arguments
* psi_container::PSIContainer : the psi_container model built in PowerSimulations
* constriant_data::Vector{DeviceEnergyTargetConstraintInfo}: Target energy storage information
* cons_name::Symbol : energy target constraint name
* var_names::Symbol : the names of the variables
- : var_names[1] : varenergy
- : var_names[2] : varslack
"""
function energy_soft_target(
    psi_container::PSIContainer,
    constriant_data::Vector{DeviceEnergyTargetConstraintInfo},
    cons_name::Symbol,
    var_names::Tuple{Symbol, Symbol},
)
    time_steps = model_time_steps(psi_container)
    name_index = (get_component_name(d) for d in constriant_data)

    varenergy = get_variable(psi_container, var_names[1])
    varslack = get_variable(psi_container, var_names[2])

    target_constraint = add_cons_container!(psi_container, cons_name, name_index, 1)

    for data in constriant_data
        name = get_component_name(data)
        target_constraint[name, 1] = JuMP.@constraint(
            psi_container.JuMPmodel,
            varenergy[name, time_steps[end]] + varslack[name, time_steps[end]] >=
            data.multiplier * data.storage_target
        )
    end

    return
end
