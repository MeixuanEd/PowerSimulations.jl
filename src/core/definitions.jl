#################################################################################
# Type Alias for long type signatures
const MinMax = NamedTuple{(:min, :max), NTuple{2, Float64}}
const NamedMinMax = Tuple{String, MinMax}
const UpDown = NamedTuple{(:up, :down), NTuple{2, Float64}}
const InOut = NamedTuple{(:in, :out), NTuple{2, Float64}}
const StartUpStages = NamedTuple{(:hot, :warm, :cold), NTuple{3, Float64}}

const BUILD_SIMULATION_TIMER = TimerOutputs.TimerOutput()
const RUN_SIMULATION_TIMER = TimerOutputs.TimerOutput()

# Type Alias for JuMP and PJ containers
const JuMPExpressionMatrix = Matrix{<:JuMP.AbstractJuMPScalar}
const PGAE = PJ.ParametrizedGenericAffExpr{Float64, JuMP.VariableRef}
const GAE = JuMP.GenericAffExpr{Float64, JuMP.VariableRef}
const JuMPAffineExpressionArray = Matrix{GAE}
const JuMPAffineExpressionVector = Vector{GAE}
const JuMPConstraintArray = JuMP.Containers.DenseAxisArray{JuMP.ConstraintRef}
const JuMPVariableArray = JuMP.Containers.DenseAxisArray{JuMP.VariableRef}
const JuMPParamArray = JuMP.Containers.DenseAxisArray{PJ.ParameterRef}
const DenseAxisArrayContainer = Dict{Symbol, JuMP.Containers.DenseAxisArray}

IS.@scoped_enum(BuildStatus, IN_PROGRESS = -1, BUILT = 0, FAILED = 1, EMPTY = 2,)

IS.@scoped_enum(RunStatus, READY = -1, SUCCESSFUL = 0, RUNNING = 1, FAILED = 2,)

IS.@scoped_enum(SOSStatusVariable, NO_VARIABLE = 1, PARAMETER = 2, VARIABLE = 3,)

# Settings constants
const UNSET_HORIZON = 0
const UNSET_INI_TIME = Dates.DateTime(0)

# Tolerance of comparisons
# MIP gap tolerances in most solvers are set to 1e-4
const ABSOLUTE_TOLERANCE = 1.0e-3
const BALANCE_SLACK_COST = 1e6
const SERVICES_SLACK_COST = 1e5
const COST_EPSILON = 1e-3
const MISSING_INITIAL_CONDITIONS_TIME_COUNT = 999.0
const SECONDS_IN_MINUTE = 60.0
const MINUTES_IN_HOUR = 60.0
const SECONDS_IN_HOUR = 3600.0
const MAX_START_STAGES = 3
const OBJECTIVE_FUNCTION_POSITIVE = 1.0
const OBJECTIVE_FUNCTION_NEGATIVE = -1.0
# The DEFAULT_RESERVE_COST value is used to avoid degeneracy of the solutions, reseve cost isn't provided.
const DEFAULT_RESERVE_COST = 1.0e-4
const KiB = 1024
const MiB = KiB * KiB
const GiB = MiB * KiB

# Interface limitations
# TODO: Remove this and use Julia's default kwarg behavior
const OPERATIONS_ACCEPTED_KWARGS = [
    :horizon,
    :initial_time,
    :use_forecast_data,
    :PTDF,
    :use_parameters,
    :optimizer,
    :warm_start,
    :balance_slack_variables,
    :services_slack_variables,
    :system_to_file,
    :constraint_duals,
    :export_pwl_vars,
]

const OPERATIONS_SOLVE_KWARGS = [:optimizer, :save_path]

const UNSUPPORTED_POWERMODELS =
    [PM.SOCBFPowerModel, PM.SOCBFConicPowerModel, PM.IVRPowerModel]

const PSI_NAME_DELIMITER = "__"

const M_VALUE = 1e6
