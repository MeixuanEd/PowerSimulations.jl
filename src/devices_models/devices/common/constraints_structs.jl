abstract type AbstractConstraintInfo end

get_component_name(d::AbstractConstraintInfo) = d.component_name

abstract type AbstractRangeConstraintInfo <: AbstractConstraintInfo end
abstract type AbstractRampConstraintInfo <: AbstractConstraintInfo end
abstract type AbstractStartConstraintInfo <: AbstractConstraintInfo end

""" Data Container to construct range constraints"""
struct DeviceRangeConstraintInfo <: AbstractRangeConstraintInfo
    component_name::String
    limits::MinMax
    additional_terms_ub::Vector{Symbol}
    additional_terms_lb::Vector{Symbol}
end

function DeviceRangeConstraintInfo(name::String, limits::MinMax)
    return DeviceRangeConstraintInfo(name, limits, Vector{Symbol}(), Vector{Symbol}())
end

function DeviceRangeConstraintInfo(name::String)
    return DeviceRangeConstraintInfo(
        name,
        (min = -Inf, max = Inf),
        Vector{Symbol}(),
        Vector{Symbol}(),
    )
end

get_component_name(d::DeviceRangeConstraintInfo) = d.component_name

struct DeviceTimeSeriesConstraintInfo
    bus_number::Int
    multiplier::Float64
    timeseries::Vector{Float64}
    range::DeviceRangeConstraintInfo
end

function DeviceTimeSeriesConstraintInfo(
    bus_number::Int,
    multiplier::Float64,
    timeseries,
    range::DeviceRangeConstraintInfo,
)
    ts::Vector{Float64} = timeseries
    return DeviceTimeSeriesConstraintInfo(bus_number, multiplier, ts, range)
end

get_component_name(d::DeviceTimeSeriesConstraintInfo) = get_component_name(d.range)
get_limits(d::DeviceTimeSeriesConstraintInfo) = d.range.limits
get_timeseries(d::DeviceTimeSeriesConstraintInfo) = d.timeseries

function DeviceTimeSeriesConstraintInfo(
    device::PSY.Device,
    multiplier_function::Function,
    ts_vector,
    get_constraint_values::Union{Function, Nothing} = nothing,
)
    name = PSY.get_name(device)
    bus_number = PSY.get_number(PSY.get_bus(device))
    multiplier = multiplier_function(device)
    if get_constraint_values === nothing
        range_constraint_info = DeviceRangeConstraintInfo(name)
    else
        range_constraint_info =
            DeviceRangeConstraintInfo(name, get_constraint_values(device))
    end
    return DeviceTimeSeriesConstraintInfo(
        bus_number,
        multiplier,
        ts_vector,
        range_constraint_info,
    )
end

struct DeviceMultiStartRangeConstraintsInfo <: AbstractRangeConstraintInfo
    component_name::String
    limits::PSY.Min_Max
    lag_ramp_limits::NamedTuple{(:startup, :shutdown), Tuple{Float64, Float64}}
    additional_terms_ub::Vector{Symbol}# [:R1, :R2]
    additional_terms_lb::Vector{Symbol}
end

function DeviceMultiStartRangeConstraintsInfo(
    component_name::String,
    limits::PSY.Min_Max,
    lag_ramp_limits::NamedTuple{(:startup, :shutdown), Tuple{Float64, Float64}},
)
    return DeviceMultiStartRangeConstraintsInfo(
        component_name,
        limits,
        lag_ramp_limits,
        Vector{Symbol}(),
        Vector{Symbol}(),
    )
end

function DeviceMultiStartRangeConstraintsInfo(component_name::String)
    return DeviceMultiStartRangeConstraintsInfo(
        component_name,
        (min = -Inf, max = Inf),
        (startup = Inf, shutdown = Inf),
        Vector{Symbol}(),
        Vector{Symbol}(),
    )
end

struct DeviceRampConstraintInfo <: AbstractRampConstraintInfo
    component_name::String
    limits::PSI.MinMax
    ic_power::InitialCondition
    ramp_limits::PSI.UpDown
    additional_terms_ub::Vector{Symbol}
    additional_terms_lb::Vector{Symbol}
end

function DeviceRampConstraintInfo(
    component_name::String,
    limits::PSY.Min_Max,
    ic_power::InitialCondition,
    ramp_limits::PSI.UpDown,
)
    return DeviceRampConstraintInfo(
        component_name,
        limits,
        ic_power,
        ramp_limits,
        Vector{Symbol}(),
        Vector{Symbol}(),
    )
end

function DeviceRampConstraintInfo(component_name::String, ic_power::InitialCondition)
    return DeviceRampConstraintInfo(
        component_name,
        (min = -Inf, max = Inf),
        ic_power,
        (up = Inf, down = Inf),
    )
end

get_limits(d::DeviceRampConstraintInfo) = d.limits
get_ic_power(d::DeviceRampConstraintInfo) = d.ic_power
get_ramp_limits(d::DeviceRampConstraintInfo) = d.ramp_limits
get_additional_terms_ub(d::DeviceRampConstraintInfo) = d.additional_terms_ub
get_additional_terms_lb(d::DeviceRampConstraintInfo) = d.additional_terms_lb

struct DeviceStartUpConstraintInfo <: AbstractStartConstraintInfo
    component_name::String
    time_limits::StartUpStages
    startup_types::Int
end

struct DeviceStartTypesConstraintInfo <: AbstractStartConstraintInfo
    component_name::String
    startup_types::Int
end

struct DeviceEnergyTargetConstraintInfo <: AbstractStartConstraintInfo
    component_name::String
    multiplier::Float64
    storage_target::Float64
end
