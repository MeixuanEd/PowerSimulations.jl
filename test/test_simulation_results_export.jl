
import PowerSimulations:
    SimulationStoreParams,
    SimulationStoreStageParams,
    get_stage_exports,
    should_export_dual,
    should_export_parameter,
    should_export_variable

function _make_params()
    sim = Dict(
        "initial_time" => Dates.DateTime("2020-01-01T00:00:00"),
        "step_resolution" => Dates.Hour(24),
        "num_steps" => 2,
    )
    stage_defs = OrderedDict(
        :ED => Dict(
            "execution_count" => 24,
            "horizon" => 12,
            "interval" => Dates.Hour(1),
            "resolution" => Dates.Hour(1),
            "base_power" => 100.0,
            "system_uuid" => Base.UUID("4076af6c-e467-56ae-b986-b466b2749572"),
        ),
        :UC => Dict(
            "execution_count" => 1,
            "horizon" => 24,
            "interval" => Dates.Hour(1),
            "resolution" => Dates.Hour(24),
            "base_power" => 100.0,
            "system_uuid" => Base.UUID("4076af6c-e467-56ae-b986-b466b2749572"),
        ),
    )
    stages = OrderedDict{Symbol, SimulationStoreStageParams}()
    for stage in keys(stage_defs)
        stage_params = SimulationStoreStageParams(
            stage_defs[stage]["execution_count"],
            stage_defs[stage]["horizon"],
            stage_defs[stage]["interval"],
            stage_defs[stage]["resolution"],
            stage_defs[stage]["base_power"],
            stage_defs[stage]["system_uuid"],
        )

        stages[stage] = stage_params
    end

    return SimulationStoreParams(
        sim["initial_time"],
        sim["step_resolution"],
        sim["num_steps"],
        stages,
    )
end

@testset "Test export from JSON" begin
    params = _make_params()
    exports = SimulationResultsExport(joinpath(DATA_DIR, "results_export.json"), params)

    valid = Dates.DateTime("2020-01-01T06:00:00")
    valid2 = Dates.DateTime("2020-01-02T23:00:00")
    invalid = Dates.DateTime("2020-01-01T02:00:00")
    invalid2 = Dates.DateTime("2020-01-03T00:00:00")

    @test should_export_variable(exports, valid, "ED", :P__ThermalStandard)
    @test should_export_variable(exports, valid2, "ED", :P__ThermalStandard)
    @test !should_export_variable(exports, invalid, "ED", :P__ThermalStandard)
    @test !should_export_variable(exports, invalid2, "ED", :P__ThermalStandard)
    @test !should_export_variable(exports, valid, "ED", :not_listed)
    @test should_export_parameter(exports, valid, "ED", :P__max_active_power__PowerLoad)
    @test !should_export_dual(exports, valid, "ED", :not_listed)

    @test should_export_variable(exports, valid, "UC", :On__ThermalStandard)
    @test !should_export_variable(exports, valid, "UC", :not_listed)
    @test should_export_parameter(exports, valid, "UC", :P__max_active_power__PowerLoad)
    @test should_export_dual(exports, valid, "UC", :any)

    @test exports.path == "export_path"
    @test exports.format == "csv"
    @test "csv" in list_supported_formats(SimulationResultsExport)
end

@testset "Invalid exports" begin
    params = _make_params()
    valid = Dates.DateTime("2020-01-01T00:00:00")
    invalid = Dates.DateTime("2020-01-03T00:00:00")

    # Invalid start_time
    @test_throws IS.InvalidValue SimulationResultsExport(
        Dict("start_time" => invalid, "stages" => [Dict("name" => "ED")]),
        params,
    )

    # Invalid end_time
    @test_throws IS.InvalidValue SimulationResultsExport(
        Dict("end_time" => invalid, "stages" => [Dict("name" => "ED")]),
        params,
    )

    # Invalid format
    @test_throws IS.InvalidValue SimulationResultsExport(
        Dict("format" => "invalid", "stages" => [Dict("name" => "ED")]),
        params,
    )

    # Missing name
    @test_throws IS.InvalidValue SimulationResultsExport(
        Dict("stages" => [Dict("variables" => [:P__ThermalStandard, :all])]),
        params,
    )

    # Can't have a variable and 'all'
    @test_throws IS.InvalidValue SimulationResultsExport(
        Dict("stages" => [Dict("name" => "ED", "variables" => [:var, :all])]),
        params,
    )
end
