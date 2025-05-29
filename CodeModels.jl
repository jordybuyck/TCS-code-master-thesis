## Step 0: Activate environment - ensure consistency accross computers
using Pkg
Pkg.activate(@__DIR__) # @__DIR__ = directory this script is in
Pkg.instantiate() # If a Manifest.toml file exist in the current project, download all the packages declared in that manifest. Else, resolve a set of feasible packages from the Project.toml files and install them.

## Step 1: read in the data
using CSV
using DataFrames

## Input data
tech_cost_lifetime = CSV.read(joinpath(@__DIR__,"InputData","Techno-economic_parameters","Investment_costs.csv"), DataFrame) # "Desktop","Burgerlijk ingenieur","Master","Fase 3 (2024-2025)","Thesis","Julia","Task OPES",
load_2025 = CSV.read(joinpath(@__DIR__,"InputData","time_series_output","Demand_2025_NationalTrends_2012.csv"), DataFrame)
wind_onshore = CSV.read(joinpath(@__DIR__,"InputData","time_series_output","onshore_2012.csv"), DataFrame)
wind_offshore = CSV.read(joinpath(@__DIR__,"InputData","time_series_output","offshore_2012.csv"), DataFrame)
pv = CSV.read(joinpath(@__DIR__,"InputData","time_series_output","pv_2012.csv"), DataFrame)
co2_price = CSV.read(joinpath(@__DIR__,"InputData","Techno-economic_parameters","co2_price.csv"), DataFrame)
fuel_costs = CSV.read(joinpath(@__DIR__,"InputData","Techno-economic_parameters","fuel_costs.csv"), DataFrame)
gen_efficiencies = CSV.read(joinpath(@__DIR__,"InputData","Techno-economic_parameters","Generator_efficiencies.csv"), DataFrame)
lines = CSV.read(joinpath(@__DIR__,"InputData","lines.csv"), DataFrame)
gen_cap = CSV.read(joinpath(@__DIR__,"InputData","gen_cap.csv"), DataFrame)
gen_prod = CSV.read(joinpath(@__DIR__,"InputData","gen_prod.csv"), DataFrame)
energy_caps = CSV.read(joinpath(@__DIR__,"InputData","hydro_capacities","energy_caps.csv"), DataFrame)
ROR_2012 = CSV.read(joinpath(@__DIR__,"InputData","time_series_output","ROR_2012.csv"), DataFrame)
PS_O_2012 = CSV.read(joinpath(@__DIR__,"InputData","time_series_output","PS_O_2012.csv"), DataFrame)
RES_2012 = CSV.read(joinpath(@__DIR__,"InputData","time_series_output","RES_2012.csv"), DataFrame)

## Output data (capacities of focus country) from endogenous model (with direct neighboring countries and with storage) -> use for IEC Submodel 3 when TCS-BM is used
cap_prod_fc_from_endo_model = CSV.read(joinpath(@__DIR__,"OutputData","Endogenous model","Cap_Prod_FC_endo_stor.csv"),DataFrame)
capstor_fc_from_endo_model = CSV.read(joinpath(@__DIR__,"OutputData","Endogenous model","CapStor_FC_endo_stor.csv"),DataFrame)

## Output data (storage variables (charge, discharge, state of charge) of neighboring countries) from IEC Submodel 3 (for TCS-BM, TCS-TYNDP and TCS-ZERO) -> use for IEC Submodel 2 when storage variables are fixed
## TCS_BM
SOC_Battery_tcs_bm = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS BM","SOC_Battery_DNC_iec_sm_3_tcs_bm.csv"),DataFrame)
SOC_PS_C_tcs_bm = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS BM","SOC_PS_C_DNC_iec_sm_3_tcs_bm.csv"),DataFrame)
SOC_PS_O_tcs_bm = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS BM","SOC_PS_O_DNC_iec_sm_3_tcs_bm.csv"),DataFrame)
SOC_RES_tcs_bm = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS BM","SOC_RES_DNC_iec_sm_3_tcs_bm.csv"),DataFrame)
SOC_ROR_tcs_bm = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS BM","SOC_ROR_DNC_iec_sm_3_tcs_bm.csv"),DataFrame)
SOC_Hydrogen_tcs_bm = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS BM","SOC_Hydrogen_DNC_iec_sm_3_tcs_bm.csv"),DataFrame)
## TCS_TYNDP
SOC_Battery_tcs_tyndp = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS TYNDP","SOC_Battery_DNC_iec_sm_3_tcs_tyndp.csv"),DataFrame)
SOC_PS_C_tcs_tyndp = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS TYNDP","SOC_PS_C_DNC_iec_sm_3_tcs_tyndp.csv"),DataFrame)
SOC_PS_O_tcs_tyndp = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS TYNDP","SOC_PS_O_DNC_iec_sm_3_tcs_tyndp.csv"),DataFrame)
SOC_RES_tcs_tyndp = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS TYNDP","SOC_RES_DNC_iec_sm_3_tcs_tyndp.csv"),DataFrame)
SOC_ROR_tcs_tyndp = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS TYNDP","SOC_ROR_DNC_iec_sm_3_tcs_tyndp.csv"),DataFrame)
SOC_Hydrogen_tcs_tyndp = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS TYNDP","SOC_Hydrogen_DNC_iec_sm_3_tcs_tyndp.csv"),DataFrame)
## TCS_ZERO
SOC_Battery_tcs_zero = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS ZERO","SOC_Battery_DNC_iec_sm_3_tcs_zero.csv"),DataFrame)
SOC_PS_C_tcs_zero = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS ZERO","SOC_PS_C_DNC_iec_sm_3_tcs_zero.csv"),DataFrame)
SOC_PS_O_tcs_zero = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS ZERO","SOC_PS_O_DNC_iec_sm_3_tcs_zero.csv"),DataFrame)
SOC_RES_tcs_zero = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS ZERO","SOC_RES_DNC_iec_sm_3_tcs_zero.csv"),DataFrame)
SOC_ROR_tcs_zero = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS ZERO","SOC_ROR_DNC_iec_sm_3_tcs_zero.csv"),DataFrame)
SOC_Hydrogen_tcs_zero = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS ZERO","SOC_Hydrogen_DNC_iec_sm_3_tcs_zero.csv"),DataFrame)

## Output data (import and export prices with corresponding AF) from IEC Submodel 2 (for TCS-NO FIXING, TCS-BM, TCS-TYNDP and TCS-ZERO) -> use for IEC Submodel 1 for import and export variables
## TCS_NO_FIXING
AF_import_tcs_no_fixing = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 2","Storage variables optimized endogenously","AF_imp_iec_sm_2_opt_stor_var_endo.csv"),DataFrame)
AF_export_tcs_no_fixing = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 2","Storage variables optimized endogenously","AF_exp_iec_sm_2_opt_stor_var_endo.csv"),DataFrame)
## TCS_BM
AF_import_tcs_bm = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 2","Fixed storage variables","Based on TCS BM","AF_imp_iec_sm_2_fix_stor_var_based_on_tcs_bm.csv"),DataFrame)
AF_export_tcs_bm = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 2","Fixed storage variables","Based on TCS BM","AF_exp_iec_sm_2_fix_stor_var_based_on_tcs_bm.csv"),DataFrame)
## TCS_TYNDP
AF_import_tcs_tyndp = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 2","Fixed storage variables","Based on TCS TYNDP","AF_imp_iec_sm_2_fix_stor_var_based_on_tcs_tyndp.csv"),DataFrame)
AF_export_tcs_tyndp = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 2","Fixed storage variables","Based on TCS TYNDP","AF_exp_iec_sm_2_fix_stor_var_based_on_tcs_tyndp.csv"),DataFrame)
## TCS_ZERO
AF_import_tcs_zero = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 2","Fixed storage variables","Based on TCS ZERO","AF_imp_iec_sm_2_fix_stor_var_based_on_tcs_zero.csv"),DataFrame)
AF_export_tcs_zero = CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 2","Fixed storage variables","Based on TCS ZERO","AF_exp_iec_sm_2_fix_stor_var_based_on_tcs_zero.csv"),DataFrame)

## Output data (real trade demand in focus country) from IEC Submodel 1 (for TCS-NO FIXING, TCS-BM, TCS-TYNDP and TCS-ZERO without and with storage unit investments) -> use for IEC Submodel 4 for demand level in focus country
## TCS_NO_FIXING
D_real_tcs_no_fix_no_stor =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS NO FIXING","Dtrade_real_FC_iec_sm_1_no_stor_tcs_no_fix.csv"),DataFrame)
D_real_tcs_no_fix_stor =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS NO FIXING","Dtrade_real_FC_iec_sm_1_stor_tcs_no_fix.csv"),DataFrame)
## TCS_BM
D_real_tcs_bm_no_stor =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS BM","Dtrade_real_FC_iec_sm_1_no_stor_tcs_bm.csv"),DataFrame)
D_real_tcs_bm_stor =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS BM","Dtrade_real_FC_iec_sm_1_stor_tcs_bm.csv"),DataFrame)
## TCS_TYNDP
D_real_tcs_tyndp_no_stor =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS TYNDP","Dtrade_real_FC_iec_sm_1_no_stor_tcs_tyndp.csv"),DataFrame)
D_real_tcs_tyndp_stor =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS TYNDP","Dtrade_real_FC_iec_sm_1_stor_tcs_tyndp.csv"),DataFrame)
## TCS_ZERO
D_real_tcs_zero_no_stor =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS ZERO","Dtrade_real_FC_iec_sm_1_no_stor_tcs_zero.csv"),DataFrame)
D_real_tcs_zero_stor =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS ZERO","Dtrade_real_FC_iec_sm_1_stor_tcs_zero.csv"),DataFrame)

## Replace missing data by zeros
for column in names(load_2025) # Call column names with 'names()' (names(load_2025,column) for specific column name)
    load_2025[!,column] = coalesce.(load_2025[!,column], 0)
end
for column in names(wind_onshore)
    wind_onshore[!,column] = coalesce.(wind_onshore[!,column], 0)
end
for column in names(wind_offshore)
    wind_offshore[!,column] = coalesce.(wind_offshore[!,column], 0)
end
for column in names(pv)
    pv[!,column] = coalesce.(pv[!,column], 0)
end
#for column in names(ROR_2012)
#    ROR_2012[!,column] = coalesce.(ROR_2012[!,column], 0)
#end
#for column in names(PS_O_2012)
#    PS_O_2012[!,column] = coalesce.(PS_O_2012[!,column], 0)
#end
#for column in names(RES_2012)
#    RES_2012[!,column] = coalesce.(RES_2012[!,column], 0)
#end

## Step 2: create model & pass data to model
using JuMP
using Gurobi
m = Model(optimizer_with_attributes(Gurobi.Optimizer))
set_optimizer_attribute(m, "Method", 1)

## Step 2a: create sets
function define_sets!(m::Model, tech_cost_lifetime::DataFrame, lines::DataFrame, gen_cap::DataFrame, gen_prod::DataFrame, AF_import_tcs_no_fixing::DataFrame, AF_export_tcs_no_fixing::DataFrame, AF_import_tcs_bm::DataFrame, AF_export_tcs_bm::DataFrame, AF_import_tcs_tyndp::DataFrame, AF_export_tcs_tyndp::DataFrame, AF_import_tcs_zero::DataFrame, AF_export_tcs_zero::DataFrame)
    ## Create dictionary to store sets
    m.ext[:sets] = Dict()
    nTimesteps = 24
    nDays = 365
    focus_country = "BE00"
    Year = 2025
    ClimateYear = 1984
    all_direct_neighboring_countries = "yes"
    ## ONLY ONE OF THE FOLLOWING FOUR OPTIONS CAN BE "yes" FOR STORAGE PROFILES
    storage_profiles_based_on_tcs_bm = "yes" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_tyndp/zero = "no"'
    storage_profiles_based_on_tcs_tyndp = "no" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_bm/zero = "no"' 
    storage_profiles_based_on_tcs_zero = "no" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_bm/tyndp = "no"'
    storage_profiles_optimized_endogenously = "no" # Only "yes" if 'storage_profiles_based_on_tcs_bm/tyndp/zero = "no"'
    lambda_needed = "no" # Only "yes" if building IEC SUBMODEL 1

    ## Define the sets
    m.ext[:sets][:JH] = 1:nTimesteps ## Timesteps
    m.ext[:sets][:JD] = 1:nDays ## Representative days

    #####################Sets single country#############################################################################################################################

    m.ext[:sets][:I] = [i for i in tech_cost_lifetime.technology] # All generation units
    m.ext[:sets][:ID] = [id for id in [tech_cost_lifetime.technology[2],tech_cost_lifetime.technology[5]]] # Dispatchable generation units
    m.ext[:sets][:IV] = [iv for iv in [tech_cost_lifetime.technology[1],tech_cost_lifetime.technology[3],tech_cost_lifetime.technology[4]]] # Variable generation units
    m.ext[:sets][:Istor] = [istor for istor in [gen_efficiencies[16,"Generator_ID"],gen_efficiencies[17,"Generator_ID"],gen_efficiencies[18,"Generator_ID"],gen_efficiencies[20,"Generator_ID"],gen_efficiencies[21,"Generator_ID"]]] # Storage units
    #m.ext[:sets][:IstorPSO] = [istor for istor in [gen_efficiencies[18,"Generator_ID"]]]
    m.ext[:sets][:IstorRES] = [istor for istor in [gen_efficiencies[20,"Generator_ID"]]]
    m.ext[:sets][:IstorROR] = [istor for istor in [gen_efficiencies[21,"Generator_ID"]]]
    m.ext[:sets][:IstorNO] = [istor for istor in [gen_efficiencies[17,"Generator_ID"],gen_efficiencies[18,"Generator_ID"],gen_efficiencies[20,"Generator_ID"],gen_efficiencies[21,"Generator_ID"]]] # Storage units focus country can not invest in
    #####################################################################################################################################################################
    
    #####################Sets direct neighboring countries###############################################################################################################

    ## Sets of considered countries
    m.ext[:sets][:C] = [focus_country] # Focus country only
    m.ext[:sets][:CDonly] = [] # Direct neighboring countries
    m.ext[:sets][:CD] = [focus_country] # Direct neighboring countries and focus country
    for row = 1:length(lines.Node1)
        if lines[row,"Year"] == Year
            if lines[row,"Climate Year"] == ClimateYear
                if lines[row,"Parameter"] == "Export Capacity"
                    if lines[row,"Node1"] == focus_country # 'getindex(gen_efficiencies[!,"Generator_ID"],1)' EQUIVALENT TO 'gen_efficiencies[1,"Generator_ID"]'
                        push!(m.ext[:sets][:CDonly],lines.Node2[row])
                        #m.ext[:sets][:CD] = [cd for cd in [gen_cap.Node[2],gen_cap.Node[3],gen_cap.Node[7],gen_cap.Node[17],gen_cap.Node[19],gen_cap.Node[28]]] # Countries in reduced model (Belgium and direct neighboring countries: FR, NL, UK, DE & LUG) 
                    elseif lines[row,"Node2"] == focus_country
                        push!(m.ext[:sets][:CDonly],lines.Node1[row])
                    end
                elseif lines[row,"Parameter"] == "Import Capacity"
                    if lines[row,"Node1"] == focus_country
                        push!(m.ext[:sets][:CDonly],lines.Node2[row])
                    elseif lines[row,"Node2"] == focus_country
                        push!(m.ext[:sets][:CDonly],lines.Node1[row])
                    end
                end
            end
        end
    end
    ## Some countries only in Node2. Add their neighbouring countries via this section
    #if m.ext[:sets][:CDonly] == []
    #    #m.ext[:sets][:CNODE2] = [] #Countries in Node 2, but not in Node 1
    #    #for node2 = unique(lines[!,"Node2"])
    #    #    if node2 ∉ unique(lines[!,"Node1"])
    #    #        push!(m.ext[:sets][:CNODE2],node2)
    #    #    end
    #    #end
    #    for row = 1:length(lines.Node1)
    #        if lines[row,"Year"] == Year
    #            if lines[row,"Climate Year"] == ClimateYear
    #                if lines[row,"Parameter"] == "Export Capacity"
    #                    if lines[row,"Node2"] == focus_country
    #                        push!(m.ext[:sets][:CDonly],lines.Node1[row])
    #                    end
    #                end
    #            end
    #        end
    #    end
    #end
    m.ext[:sets][:CDonly] = unique(m.ext[:sets][:CDonly])
    deleteat!(m.ext[:sets][:CDonly], findall(x->x=="LUB1",m.ext[:sets][:CDonly])) # Ignore "LUB1" since only battery capacity and low demand
    deleteat!(m.ext[:sets][:CDonly], findall(x->x=="LUG1",m.ext[:sets][:CDonly])) # Ignore "LUG1" since not much capacities and demand
    ## Add scandinavian countries
    #for country_scan in ["NOM1","NON1","NOS0"] #["FI00","SE01","SE02","SE03","SE04","NOM1","NON1","NOS0","DKW1","DKE1"]
    #    push!(m.ext[:sets][:CDonly],country_scan)
    #end
    for country in m.ext[:sets][:CDonly]
        m.ext[:sets][:CD] = push!(m.ext[:sets][:CD],country)
    end

    ## Test with only one direct neighbouring country
    if all_direct_neighboring_countries == "no"
        m.ext[:sets][:CD] = ["BE00","FR00"] # focus country and direct neighboring country
        m.ext[:sets][:CDonly] = ["FR00"] # Direct neighbouring country
    end
    
    ## Lines of focus country (as vector)
    LinesfocuscountryVector = m.ext[:sets][:LinesfocuscountryVector] = []
    for row = 1:length(lines.Node1) # Actually only 10447:10644 needed
        if lines[row,"Year"] == Year
            if lines[row,"Climate Year"] == ClimateYear
                if lines[row,"Parameter"] == "Export Capacity"
                    if lines[row,"Node1"] == focus_country
                            if lines[row,"Node2"] ∈ m.ext[:sets][:CDonly]
                                push!(m.ext[:sets][:LinesfocuscountryVector],lines[row,"Node/Line"])
                            end
                    elseif lines[row,"Node2"] == focus_country
                            if lines[row,"Node1"] ∈ m.ext[:sets][:CDonly]
                                push!(m.ext[:sets][:LinesfocuscountryVector],lines[row,"Node/Line"])
                            end
                    end
                elseif lines[row,"Parameter"] == "Import Capacity"
                    if lines[row,"Node1"] == focus_country
                            if lines[row,"Node2"] ∈ m.ext[:sets][:CDonly]
                                push!(m.ext[:sets][:LinesfocuscountryVector],lines[row,"Node/Line"])
                            end
                    elseif lines[row,"Node2"] == focus_country
                            if lines[row,"Node1"] ∈ m.ext[:sets][:CDonly]
                                push!(m.ext[:sets][:LinesfocuscountryVector],lines[row,"Node/Line"])
                            end
                    end
                end
            end
        end
    end
    m.ext[:sets][:LinesfocuscountryVector] = unique(m.ext[:sets][:LinesfocuscountryVector])

    ## Lines of focus country and direct neighbouring countries (as vector)
    LinescdVector = m.ext[:sets][:LinescdVector] = []
    for line in m.ext[:sets][:LinesfocuscountryVector]
        m.ext[:sets][:LinescdVector] = push!(m.ext[:sets][:LinescdVector],line)
    end
    for row = 1:length(lines.Node1), country in m.ext[:sets][:CDonly]
        if lines[row,"Year"] == Year
            if lines[row,"Climate Year"] == ClimateYear
                if lines[row,"Parameter"] == "Export Capacity"
                    if lines[row,"Node1"] == country
                        if lines[row,"Node2"] ∈ m.ext[:sets][:CD]
                            push!(m.ext[:sets][:LinescdVector],lines[row,"Node/Line"])
                        end
                    elseif lines[row,"Node2"] == country
                        if lines[row,"Node1"] ∈ m.ext[:sets][:CD]
                            push!(m.ext[:sets][:LinescdVector],lines[row,"Node/Line"])
                        end
                    end
                elseif lines[row,"Parameter"] == "Import Capacity"
                    if lines[row,"Node1"] == country
                        if lines[row,"Node2"] ∈ m.ext[:sets][:CD]
                            push!(m.ext[:sets][:LinescdVector],lines[row,"Node/Line"])
                        end
                    elseif lines[row,"Node2"] == country
                        if lines[row,"Node1"] ∈ m.ext[:sets][:CD]
                            push!(m.ext[:sets][:LinescdVector],lines[row,"Node/Line"])
                        end
                    end
                end
            end
        end
    end
    m.ext[:sets][:LinescdVector] = unique(m.ext[:sets][:LinescdVector]) 

    ## Lines of focus country (as dictionary)
    Linesfocuscountry = m.ext[:sets][:Linesfocuscountry] = Dict()
    for line in LinesfocuscountryVector, row = 1:length(lines.Node1)
        if line == lines[row,"Node/Line"]
            m.ext[:sets][:Linesfocuscountry][line] = lines[row,"Node1"], lines[row,"Node2"]
        end
    end

    ## Lines of focus country and direct neighbouring countries (as dictionary)
    m.ext[:sets][:Linescd] = Dict()
    for line in LinesfocuscountryVector
        m.ext[:sets][:Linescd][line] = Linesfocuscountry[line]
    end
    for line in LinescdVector, row = 1:length(lines.Node1)
        if line == lines[row,"Node/Line"]
            m.ext[:sets][:Linescd][line] = lines[row,"Node1"], lines[row,"Node2"]
        end
    end

    ## Sets of generation units for all direct neigboring countries
    m.ext[:sets][:IDcd] = ["Oil_light", "Oil_heavy", "Coal", "OCGT", "Lignite", "Coal_bio", "CCGT", "Nuclear"] # Without Scandinavian countries
    #m.ext[:sets][:IDcd] = ["CCGT_bio","OCGT_bio","Oil_heavy_bio","Oil_light", "Oil_heavy", "Coal", "OCGT", "Lignite", "Coal_bio", "CCGT", "Nuclear"] # With Scandinavian countries
    m.ext[:sets][:IVcd] = []
    for iv in m.ext[:sets][:IV]
        push!(m.ext[:sets][:IVcd],iv)
    end
    m.ext[:sets][:Icd] = union(m.ext[:sets][:IDcd],m.ext[:sets][:IVcd])

    ## Sets of generation units that focus country is not allowed to invest in
    m.ext[:sets][:Iextra] = []
    for icd in m.ext[:sets][:Icd]
        if icd ∉ m.ext[:sets][:I]
            m.ext[:sets][:Iextra] = push!(m.ext[:sets][:Iextra],icd)
        end
    end

    ## 'Sets' of generation units that provide free flat electricity production
    m.ext[:sets][:IFreeFlat] = Dict() # [MW]
    for cd in m.ext[:sets][:CD]
        m.ext[:sets][:IFreeFlat][cd,"Other Non RES"] = 0
        m.ext[:sets][:IFreeFlat][cd,"Other RES"] = 0
    end
    for cd in m.ext[:sets][:CD], row = 1:length(gen_prod.Node)
        if gen_prod.Node[row] == cd
            if gen_prod[row,"Year"] == Year
                if gen_prod[row,"Climate Year"] == ClimateYear
                    if gen_prod[row,"Generator_ID"] == "Other Non RES"
                        m.ext[:sets][:IFreeFlat][cd,"Other Non RES"] = m.ext[:sets][:IFreeFlat][cd,"Other Non RES"] + gen_prod.Value[row] * 1000 / (nTimesteps * nDays)
                    elseif gen_prod[row,"Generator_ID"] == "Other RES"
                        m.ext[:sets][:IFreeFlat][cd,"Other RES"] = m.ext[:sets][:IFreeFlat][cd,"Other RES"] + gen_prod.Value[row] * 1000 / (nTimesteps * nDays)
                    end
                end
            end
        end
    end

    m.ext[:sets][:Istorcd] = [istorcd for istorcd in [gen_efficiencies[16,"Generator_ID"],gen_efficiencies[17,"Generator_ID"],gen_efficiencies[18,"Generator_ID"],gen_efficiencies[20,"Generator_ID"],gen_efficiencies[21,"Generator_ID"]]]
    ## Only add limited storage technologies: remove '#' in following line
    #m.ext[:sets][:Istorcd] = [istorcd for istorcd in [gen_efficiencies[16,"Generator_ID"],gen_efficiencies[17,"Generator_ID"]]]
    m.ext[:sets][:IstorcdRES] = [istorcd for istorcd in [gen_efficiencies[20,"Generator_ID"]]]
    m.ext[:sets][:IstorcdROR] = [istorcd for istorcd in [gen_efficiencies[21,"Generator_ID"]]]
    #####################################################################################################################################################################

    ######################################################################IEC Submodel 1#################################################################################
    
    ## Sets for import and export
    m.ext[:sets][:Pimp] = []
    m.ext[:sets][:Pexp] = []
    if lambda_needed == "yes"
        if storage_profiles_optimized_endogenously == "yes" # Sets for import and export based on Submodel 2 when using TCS-NO FIXING
            for import_price in names(AF_import_tcs_no_fixing)
                if import_price !== "Timestep"
                    m.ext[:sets][:Pimp] = push!(m.ext[:sets][:Pimp],import_price)
                end
            end
            for export_price in names(AF_export_tcs_no_fixing)
                if export_price !== "Timestep"
                    m.ext[:sets][:Pexp] = push!(m.ext[:sets][:Pexp],export_price)
                end
            end
        elseif storage_profiles_based_on_tcs_bm == "yes" # Sets for import and export based on Submodel 2 when using TCS-BM
            for import_price in names(AF_import_tcs_bm)
                if import_price !== "Timestep"
                    m.ext[:sets][:Pimp] = push!(m.ext[:sets][:Pimp],import_price)
                end
            end
            for export_price in names(AF_export_tcs_bm)
                if export_price !== "Timestep"
                    m.ext[:sets][:Pexp] = push!(m.ext[:sets][:Pexp],export_price)
                end
            end
        elseif storage_profiles_based_on_tcs_tyndp == "yes" # Sets for import and export based on Submodel 2 when using TCS-TYNDP
            for import_price in names(AF_import_tcs_tyndp)
                if import_price !== "Timestep"
                    m.ext[:sets][:Pimp] = push!(m.ext[:sets][:Pimp],import_price)
                end
            end
            for export_price in names(AF_export_tcs_tyndp)
                if export_price !== "Timestep"
                    m.ext[:sets][:Pexp] = push!(m.ext[:sets][:Pexp],export_price)
                end
            end
        elseif storage_profiles_based_on_tcs_zero == "yes" # Sets for import and export based on Submodel 2 when using TCS-ZERO
            for import_price in names(AF_import_tcs_zero)
                if import_price !== "Timestep"
                    m.ext[:sets][:Pimp] = push!(m.ext[:sets][:Pimp],import_price)
                end
            end
            for export_price in names(AF_export_tcs_zero)
                if export_price !== "Timestep"
                    m.ext[:sets][:Pexp] = push!(m.ext[:sets][:Pexp],export_price)
                end
            end
        end
    end
    #####################################################################################################################################################################

    ## Return model
    return m
end

## Step 2b: add time series
function process_time_series_data!(m::Model, load_2025::DataFrame, wind_onshore::DataFrame, wind_offshore::DataFrame, pv::DataFrame, ROR_2012::DataFrame, PS_O_2012::DataFrame, RES_2012::DataFrame, AF_import_tcs_no_fixing::DataFrame, AF_export_tcs_no_fixing::DataFrame, AF_import_tcs_bm::DataFrame, AF_export_tcs_bm::DataFrame, AF_import_tcs_tyndp::DataFrame, AF_export_tcs_tyndp::DataFrame, AF_import_tcs_zero::DataFrame, AF_export_tcs_zero::DataFrame, D_real_tcs_no_fix_no_stor::DataFrame, D_real_tcs_no_fix_stor::DataFrame, D_real_tcs_bm_no_stor::DataFrame, D_real_tcs_bm_stor::DataFrame, D_real_tcs_tyndp_no_stor::DataFrame, D_real_tcs_tyndp_stor::DataFrame, D_real_tcs_zero_no_stor::DataFrame, D_real_tcs_zero_stor::DataFrame)
    nTimesteps = 24
    focus_country = "BE00"
    tyndp_iec_sm3 = "no" # "yes" or "no" -> ONLY YES IF "tcs_zero_iec_sm3 = "no""!
    tcs_zero_iec_sm3 = "no" # "yes" or "no" -> ONLY YES IF "tyndp_iec_sm3 = "no""!
    ## ONLY ONE OF THE FOLLOWING FOUR OPTIONS CAN BE "yes" FOR STORAGE PROFILES
    storage_profiles_based_on_tcs_bm = "yes" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_tyndp/zero = "no"'
    storage_profiles_based_on_tcs_tyndp = "no" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_bm/zero = "no"' 
    storage_profiles_based_on_tcs_zero = "no" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_bm/tyndp = "no"'
    storage_profiles_optimized_endogenously = "no" # Only "yes" if 'storage_profiles_based_on_tcs_bm/tyndp/zero = "no"'
    storage_unit_investments_allowed = "yes" # "yes" or "no"
    lambda_needed = "no" # Only "yes" if building IEC SUBMODEL 1
    
    ## Extract the relevant sets
    JH = m.ext[:sets][:JH] # Time steps
    JD = m.ext[:sets][:JD] # Days
    IV = m.ext[:sets][:IV] # Variable generators
    IFreeFlat = m.ext[:sets][:IFreeFlat] # Other RES and Non RES flat free generation -> substract from demand
    CD = m.ext[:sets][:CD] # Direct neighboring countries and focus country
    CDonly = m.ext[:sets][:CDonly] # Direct neighboring countries
    Pimp = m.ext[:sets][:Pimp] # Import prices
    Pexp = m.ext[:sets][:Pexp] # Export prices

    ## Create dictionary to store time series
    m.ext[:timeseries] = Dict()
    m.ext[:timeseries][:DEMANDcd] = Dict()
    m.ext[:timeseries][:AF] = Dict()
    m.ext[:timeseries][:AFcd] = Dict()
    m.ext[:timeseries][:AFimp] = Dict()
    m.ext[:timeseries][:AFexp] = Dict()
    m.ext[:timeseries][:inflowc] = Dict()
    m.ext[:timeseries][:inflow] = Dict()

    #####################Timeseries single country#######################################################################################################################

    ## Add time series to dictionary (single country)
    ## Demand - [MW]
    m.ext[:timeseries][:DEMAND] = [load_2025.BE00[jh + nTimesteps * (jd - 1)] for jh in JH, jd in JD] # [MW]

    ## Availability factor - [-]
    m.ext[:timeseries][:AF][IV[1]] = [wind_offshore.BE00[jh + nTimesteps * (jd - 1)] for jh in JH, jd in JD] # [-]
    m.ext[:timeseries][:AF][IV[2]] = [wind_onshore.BE00[jh + nTimesteps * (jd - 1)] for jh in JH, jd in JD] # [-]
    m.ext[:timeseries][:AF][IV[3]] = [pv.BE00[jh + nTimesteps * (jd - 1)] for jh in JH, jd in JD] # [-]

    ## Inflow of storage technologies - [MW]
    m.ext[:timeseries][:inflowc]["PS_C"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD]
    m.ext[:timeseries][:inflowc]["Battery"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD]
    m.ext[:timeseries][:inflowc]["PS_O"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD] #[PS_O_2012[jh + nTimesteps * (jd - 1),"BG00"] for jh in JH, jd in JD]
    m.ext[:timeseries][:inflowc]["RES"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD] #[RES_2012[jh + nTimesteps * (jd - 1),"BG00"] for jh in JH, jd in JD]
    m.ext[:timeseries][:inflowc]["ROR"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD] #[ROR_2012[jh + nTimesteps * (jd - 1),"BG00"] for jh in JH, jd in JD]
    m.ext[:timeseries][:inflowc]["Hydrogen"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD]
    #####################################################################################################################################################################

    #####################Timeseries direct neighbouring countries########################################################################################################

    ## Add time series (for focus country) and subtract free flat 'Other Non RES' and 'Other RES' from it (for direct neighbouring countries)
    for cd in CD
        if tcs_zero_iec_sm3 == "no"
            if tyndp_iec_sm3 == "no"    
                if cd == focus_country
                    m.ext[:timeseries][:DEMANDcd][cd] = [load_2025[jh + nTimesteps * (jd - 1),cd] for jh in JH, jd in JD] # [MW]
                else
                    m.ext[:timeseries][:DEMANDcd][cd] = [load_2025[jh + nTimesteps * (jd - 1),cd] - IFreeFlat[cd,"Other Non RES"] - IFreeFlat[cd,"Other RES"] for jh in JH, jd in JD] # [MW]
                end
            elseif tyndp_iec_sm3 == "yes"
                m.ext[:timeseries][:DEMANDcd][cd] = [load_2025[jh + nTimesteps * (jd - 1),cd] - IFreeFlat[cd,"Other Non RES"] - IFreeFlat[cd,"Other RES"] for jh in JH, jd in JD] # [MW]
            end
        elseif tcs_zero_iec_sm3 == "yes" # Zero demand in focus country if using TCS-ZERO model
            if cd == focus_country
                m.ext[:timeseries][:DEMANDcd][cd] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD] # [MW]
            else
                m.ext[:timeseries][:DEMANDcd][cd] = [load_2025[jh + nTimesteps * (jd - 1),cd] - IFreeFlat[cd,"Other Non RES"] - IFreeFlat[cd,"Other RES"] for jh in JH, jd in JD] # [MW]
            end
        end
    end

    ## Availability factors of renewable energy generators for each country - [-]
    index = 1
    for cd in CD
        m.ext[:timeseries][:AFcd][IV[1],CD[index]] = [wind_offshore[jh + nTimesteps * (jd - 1),cd] for jh in JH, jd in JD] # [-]
        m.ext[:timeseries][:AFcd][IV[2],CD[index]] = [wind_onshore[jh + nTimesteps * (jd - 1),cd] for jh in JH, jd in JD] # [-]
        m.ext[:timeseries][:AFcd][IV[3],CD[index]] = [pv[jh + nTimesteps * (jd - 1),cd] for jh in JH, jd in JD] # [-]
        index = index + 1
    end

    ## Inflow of storage technologies - [MW]
    for cd in CD
        m.ext[:timeseries][:inflow][cd,"PS_C"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD]
        m.ext[:timeseries][:inflow][cd,"Battery"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD]
        m.ext[:timeseries][:inflow][cd,"Hydrogen"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD]
        if cd == focus_country
            if tyndp_iec_sm3 == "no" # No storage units allowed in focus country
                m.ext[:timeseries][:inflow][cd,"PS_O"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD]
                m.ext[:timeseries][:inflow][cd,"RES"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD]
                m.ext[:timeseries][:inflow][cd,"ROR"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD]
            elseif tyndp_iec_sm3 == "yes" # Storage units allowed in focus country
                m.ext[:timeseries][:inflow][cd,"PS_O"] = [PS_O_2012[jh + nTimesteps * (jd - 1),"BG00"] for jh in JH, jd in JD]
                m.ext[:timeseries][:inflow][cd,"RES"] = [RES_2012[jh + nTimesteps * (jd - 1),"BG00"] for jh in JH, jd in JD]
                m.ext[:timeseries][:inflow][cd,"ROR"] = [ROR_2012[jh + nTimesteps * (jd - 1),"BG00"] for jh in JH, jd in JD]
            end
        elseif cd == "UK00"
            m.ext[:timeseries][:inflow][cd,"PS_O"] = [last(PS_O_2012[jh + nTimesteps * (jd - 1),:]) for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"RES"] = [last(RES_2012[jh + nTimesteps * (jd - 1),:]) for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"ROR"] = [last(ROR_2012[jh + nTimesteps * (jd - 1),:]) for jh in JH, jd in JD]
        elseif cd == "DE00"
            m.ext[:timeseries][:inflow][cd,"PS_O"] = [PS_O_2012[jh + nTimesteps * (jd - 1),"ES00"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"RES"] = [RES_2012[jh + nTimesteps * (jd - 1),"ES00"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"ROR"] = [ROR_2012[jh + nTimesteps * (jd - 1),"ES00"] for jh in JH, jd in JD]
        elseif cd == "FR00"
            m.ext[:timeseries][:inflow][cd,"PS_O"] = [PS_O_2012[jh + nTimesteps * (jd - 1),"GR00"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"RES"] = [RES_2012[jh + nTimesteps * (jd - 1),"GR00"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"ROR"] = [ROR_2012[jh + nTimesteps * (jd - 1),"GR00"] for jh in JH, jd in JD]
        elseif cd == "NL00"
            m.ext[:timeseries][:inflow][cd,"PS_O"] = [PS_O_2012[jh + nTimesteps * (jd - 1),"NOM1"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"RES"] = [RES_2012[jh + nTimesteps * (jd - 1),"NOM1"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"ROR"] = [ROR_2012[jh + nTimesteps * (jd - 1),"NOM1"] for jh in JH, jd in JD]
        elseif cd == "FI00"
            m.ext[:timeseries][:inflow][cd,"PS_O"] = [PS_O_2012[jh + nTimesteps * (jd - 1),"FR00"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"RES"] = [RES_2012[jh + nTimesteps * (jd - 1),"FR00"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"ROR"] = [ROR_2012[jh + nTimesteps * (jd - 1),"FR00"] for jh in JH, jd in JD]
        elseif cd == "SE01"
            m.ext[:timeseries][:inflow][cd,"PS_O"] = [PS_O_2012[jh + nTimesteps * (jd - 1),"SE02"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"RES"] = [RES_2012[jh + nTimesteps * (jd - 1),"SE02"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"ROR"] = [ROR_2012[jh + nTimesteps * (jd - 1),"SE02"] for jh in JH, jd in JD]
        elseif cd == "SE02"
            m.ext[:timeseries][:inflow][cd,"PS_O"] = [PS_O_2012[jh + nTimesteps * (jd - 1),"SE03"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"RES"] = [RES_2012[jh + nTimesteps * (jd - 1),"SE03"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"ROR"] = [ROR_2012[jh + nTimesteps * (jd - 1),"SE03"] for jh in JH, jd in JD]
        elseif cd == "SE03"
            m.ext[:timeseries][:inflow][cd,"PS_O"] = [PS_O_2012[jh + nTimesteps * (jd - 1),"SE04"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"RES"] = [RES_2012[jh + nTimesteps * (jd - 1),"SE04"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"ROR"] = [ROR_2012[jh + nTimesteps * (jd - 1),"SE04"] for jh in JH, jd in JD]
        elseif cd == "SE04"
            m.ext[:timeseries][:inflow][cd,"PS_O"] = [PS_O_2012[jh + nTimesteps * (jd - 1),"SI00"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"RES"] = [RES_2012[jh + nTimesteps * (jd - 1),"SI00"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"ROR"] = [ROR_2012[jh + nTimesteps * (jd - 1),"SI00"] for jh in JH, jd in JD]
        elseif cd == "NOM1"
            m.ext[:timeseries][:inflow][cd,"PS_O"] = [PS_O_2012[jh + nTimesteps * (jd - 1),"NON1"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"RES"] = [RES_2012[jh + nTimesteps * (jd - 1),"NON1"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"ROR"] = [ROR_2012[jh + nTimesteps * (jd - 1),"NON1"] for jh in JH, jd in JD]
        elseif cd == "NON1"
            m.ext[:timeseries][:inflow][cd,"PS_O"] = [PS_O_2012[jh + nTimesteps * (jd - 1),"NOS0"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"RES"] = [RES_2012[jh + nTimesteps * (jd - 1),"NOS0"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"ROR"] = [ROR_2012[jh + nTimesteps * (jd - 1),"NOS0"] for jh in JH, jd in JD]
        elseif cd == "NOS0"
            m.ext[:timeseries][:inflow][cd,"PS_O"] = [PS_O_2012[jh + nTimesteps * (jd - 1),"PL00"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"RES"] = [RES_2012[jh + nTimesteps * (jd - 1),"PL00"] for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"ROR"] = [ROR_2012[jh + nTimesteps * (jd - 1),"PL00"] for jh in JH, jd in JD]
        elseif cd == "DKW1"
            m.ext[:timeseries][:inflow][cd,"PS_O"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"RES"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"ROR"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD]
        elseif cd == "DKE1"
            m.ext[:timeseries][:inflow][cd,"PS_O"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"RES"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD]
            m.ext[:timeseries][:inflow][cd,"ROR"] = [0*(jh + nTimesteps * (jd - 1)) for jh in JH, jd in JD]
        end
    end
    #####################################################################################################################################################################
    
    ######################################################################IEC Submodel 1#################################################################################

    ## Availability factor of import - [MW]
    if lambda_needed == "yes"
        for import_price in Pimp
            if storage_profiles_optimized_endogenously == "yes" # AF of import based on Submodel 2 when using TCS-NO FIXING
                m.ext[:timeseries][:AFimp][import_price] = [AF_import_tcs_no_fixing[jh + nTimesteps * (jd - 1),import_price] for jh in JH, jd in JD] # [MW]
            elseif storage_profiles_based_on_tcs_bm == "yes" # AF of import based on Submodel 2 when using TCS-BM
                m.ext[:timeseries][:AFimp][import_price] = [AF_import_tcs_bm[jh + nTimesteps * (jd - 1),import_price] for jh in JH, jd in JD] # [MW]
            elseif storage_profiles_based_on_tcs_tyndp == "yes" # AF of import based on Submodel 2 when using TCS-TYNDP
                m.ext[:timeseries][:AFimp][import_price] = [AF_import_tcs_tyndp[jh + nTimesteps * (jd - 1),import_price] for jh in JH, jd in JD] # [MW]
            elseif storage_profiles_based_on_tcs_zero == "yes" # AF of import based on Submodel 2 when using TCS-ZERO
                m.ext[:timeseries][:AFimp][import_price] = [AF_import_tcs_zero[jh + nTimesteps * (jd - 1),import_price] for jh in JH, jd in JD] # [MW]
            end
        end
    end
    ## Availability factor of export - [MW]
    if lambda_needed == "yes"
        for export_price in Pexp
            if storage_profiles_optimized_endogenously == "yes" # AF of export based on Submodel 2 when using TCS-NO FIXING
                m.ext[:timeseries][:AFexp][export_price] = [AF_export_tcs_no_fixing[jh + nTimesteps * (jd - 1),export_price] for jh in JH, jd in JD] # [MW]
            elseif storage_profiles_based_on_tcs_bm == "yes" # AF of export based on Submodel 2 when using TCS-BM
                m.ext[:timeseries][:AFexp][export_price] = [AF_export_tcs_bm[jh + nTimesteps * (jd - 1),export_price] for jh in JH, jd in JD] # [MW]
            elseif storage_profiles_based_on_tcs_tyndp == "yes" # AF of export based on Submodel 2 when using TCS-TYNDP
                m.ext[:timeseries][:AFexp][export_price] = [AF_export_tcs_tyndp[jh + nTimesteps * (jd - 1),export_price] for jh in JH, jd in JD] # [MW]
            elseif storage_profiles_based_on_tcs_zero == "yes" # AF of export based on Submodel 2 when using TCS-ZERO
                m.ext[:timeseries][:AFexp][export_price] = [AF_export_tcs_zero[jh + nTimesteps * (jd - 1),export_price] for jh in JH, jd in JD] # [MW]
            end
        end
    end
    #####################################################################################################################################################################

    ######################################################################IEC Submodel 4#################################################################################

    ## Real demand profile for focus country for IEC Submodel 4 (without and with storage unit investments and based on TCS-NO FIXING/BM/TYNDP/ZERO) - [MW]
    if storage_unit_investments_allowed == "no"
        if storage_profiles_optimized_endogenously == "yes"
            m.ext[:timeseries][:Dc_trade_real] = [D_real_tcs_no_fix_no_stor[jh + nTimesteps * (jd - 1),"Real trade demand focus country"] for jh in JH, jd in JD] # [MW]
        elseif storage_profiles_based_on_tcs_bm == "yes"
            m.ext[:timeseries][:Dc_trade_real] = [D_real_tcs_bm_no_stor[jh + nTimesteps * (jd - 1),"Real trade demand focus country"] for jh in JH, jd in JD] # [MW]
        elseif storage_profiles_based_on_tcs_tyndp == "yes"
            m.ext[:timeseries][:Dc_trade_real] = [D_real_tcs_tyndp_no_stor[jh + nTimesteps * (jd - 1),"Real trade demand focus country"] for jh in JH, jd in JD] # [MW]
        elseif storage_profiles_based_on_tcs_zero == "yes"
            m.ext[:timeseries][:Dc_trade_real] = [D_real_tcs_zero_no_stor[jh + nTimesteps * (jd - 1),"Real trade demand focus country"] for jh in JH, jd in JD] # [MW]
        end
    elseif storage_unit_investments_allowed == "yes"
        if storage_profiles_optimized_endogenously == "yes"
            m.ext[:timeseries][:Dc_trade_real] = [D_real_tcs_no_fix_stor[jh + nTimesteps * (jd - 1),"Real trade demand focus country"] for jh in JH, jd in JD] # [MW]
        elseif storage_profiles_based_on_tcs_bm == "yes"
            m.ext[:timeseries][:Dc_trade_real] = [D_real_tcs_bm_stor[jh + nTimesteps * (jd - 1),"Real trade demand focus country"] for jh in JH, jd in JD] # [MW]
        elseif storage_profiles_based_on_tcs_tyndp == "yes"
            m.ext[:timeseries][:Dc_trade_real] = [D_real_tcs_tyndp_stor[jh + nTimesteps * (jd - 1),"Real trade demand focus country"] for jh in JH, jd in JD] # [MW]
        elseif storage_profiles_based_on_tcs_zero == "yes"
            m.ext[:timeseries][:Dc_trade_real] = [D_real_tcs_zero_stor[jh + nTimesteps * (jd - 1),"Real trade demand focus country"] for jh in JH, jd in JD] # [MW]
        end
    end
    #####################################################################################################################################################################

    ## Return model
    return m
end

## Step 2c: process input parameters
function process_parameters!(m::Model, co2_price::DataFrame, fuel_costs::DataFrame, gen_efficiencies::DataFrame, tech_cost_lifetime::DataFrame, gen_cap::DataFrame, lines::DataFrame, energy_caps::DataFrame, cap_prod_fc_from_endo_model::DataFrame, capstor_fc_from_endo_model::DataFrame, SOC_Battery_tcs_bm::DataFrame, SOC_PS_C_tcs_bm::DataFrame, SOC_PS_O_tcs_bm::DataFrame, SOC_RES_tcs_bm::DataFrame, SOC_ROR_tcs_bm::DataFrame, SOC_Hydrogen_tcs_bm::DataFrame, SOC_Battery_tcs_tyndp::DataFrame, SOC_PS_C_tcs_tyndp::DataFrame, SOC_PS_O_tcs_tyndp::DataFrame, SOC_RES_tcs_tyndp::DataFrame, SOC_ROR_tcs_tyndp::DataFrame, SOC_Hydrogen_tcs_tyndp::DataFrame, SOC_Battery_tcs_zero::DataFrame, SOC_PS_C_tcs_zero::DataFrame, SOC_PS_O_tcs_zero::DataFrame, SOC_RES_tcs_zero::DataFrame, SOC_ROR_tcs_zero::DataFrame, SOC_Hydrogen_tcs_zero::DataFrame)
    ## Fixed values you choose
    VOLL = 8000 # Value of Lost Load - [EUR/MWh]
    disc_rate = 0.07 # Discount rate - [-]
    phi = 0.10 # Cost of transmission due to transmission losses - [EUR/MWh]
    Year = 2025
    ClimateYear = 1984
    focus_country = "BE00"
    tyndp_iec_sm3 = "no" # "no" or "yes" -> ONLY YES IF "tcs_zero_iec_sm3 = "no""!
    all_possible_trade_levels = "yes"
    nTimesteps = 24
    lambda_needed = "no" # Only "yes" if building IEC SUBMODEL 1

    ## Extract the sets you need
    JH = m.ext[:sets][:JH]
    JD = m.ext[:sets][:JD]
    ID = m.ext[:sets][:ID]
    IDcd = m.ext[:sets][:IDcd]
    I = m.ext[:sets][:I]
    Icd = m.ext[:sets][:Icd]
    Iextra = m.ext[:sets][:Iextra]
    Istor = m.ext[:sets][:Istor]
    Istorcd = m.ext[:sets][:Istorcd]
    CD = m.ext[:sets][:CD]
    CDonly = m.ext[:sets][:CDonly]
    LinesfocuscountryVector = m.ext[:sets][:LinesfocuscountryVector]
    LinescdVector = m.ext[:sets][:LinescdVector]
    Linescd = m.ext[:sets][:Linescd]
    Pimp = m.ext[:sets][:Pimp]
    Pexp = m.ext[:sets][:Pexp]

    ## Generate a dictonary for the parameters
    m.ext[:parameters] = Dict()

    ## Input parameters
    αCO2 = m.ext[:parameters][:αCO2] = co2_price[1,string(Year)] # EUR/ton
    m.ext[:parameters][:VOLL] = VOLL # VOLL
    r = m.ext[:parameters][:discountrate] = disc_rate # Discount rate
    m.ext[:parameters][:PHI] = phi # Cost for transmitting electricity

    #####################Parameters Single country#######################################################################################################################
    
    ## Variable costs (single country)
    β = m.ext[:parameters][:β] = Dict() # [EUR/MWh] (data expressed in EUR/GJ = EUR/GWs -> EUR/GWs * 3600s/h / (1000MW/GW) = EUR/GWs*3.6 = EUR/MWh)
    for id = ID, fuel = 1:length(fuel_costs.FT)
        if id == "CCGT"
            if fuel_costs[fuel,"FT"] == "Natural gas"
                m.ext[:parameters][:β][id] = fuel_costs[fuel,string(Year)] * 3.6
            end
        elseif id == "OCGT"
            if fuel_costs[fuel,"FT"] == "Natural gas"
                m.ext[:parameters][:β][id] = fuel_costs[fuel,string(Year)] * 3.6
            end
        end
    end

    δ = m.ext[:parameters][:δ] = Dict() # [ton/MWh] (data expressed in kg/MWh -> kg/MWh / (1000kg/ton) = kg/MWh / 1000 = ton/MWh)
    for id = ID, gen = 1:length(gen_efficiencies.Generator_ID)
        if gen_efficiencies[gen,"Generator_ID"] == id
            m.ext[:parameters][:δ][id] = gen_efficiencies[gen,"emissions(kg/MWh)"] / 1000
        end
    end

    efficiency = m.ext[:parameters][:efficiency] = Dict() # [-]
    for id = ID, gen = 1:length(gen_efficiencies.Generator_ID)
        if gen_efficiencies[gen,"Generator_ID"] == id
            m.ext[:parameters][:efficiency][id] = gen_efficiencies[gen,"efficiency"]
        end
    end

    VOM = m.ext[:parameters][:VOM] = Dict() # [EUR/MWh]
    for id = ID, gen = 1:length(gen_efficiencies.Generator_ID)
        if gen_efficiencies[gen,"Generator_ID"] == id
            m.ext[:parameters][:VOM][id] = gen_efficiencies[gen,"VOM"]
        end
    end
    
    m.ext[:parameters][:VC] = Dict(id => β[id]/efficiency[id] + αCO2*δ[id]/efficiency[id] + VOM[id] for id in ID) # Variable costs - [EUR/MWh]

    ## Investment costs (single country)
    OC = m.ext[:parameters][:OC] = Dict() # [EUR/MW]
    for i = I, row in 1:length(tech_cost_lifetime.technology)
        if tech_cost_lifetime[row, "technology"] == i
            m.ext[:parameters][:OC][i] = tech_cost_lifetime.cost[row]
        end
    end

    LifeTime = m.ext[:parameters][:LT] = Dict() # [year]
    for i = I, row in 1:length(tech_cost_lifetime.technology)
        if tech_cost_lifetime[row, "technology"] == i
            m.ext[:parameters][:LT][i] = tech_cost_lifetime.lifetime[row]
        end
    end
    
    m.ext[:parameters][:IC] = Dict(i => (r * OC[i])/((1 - (1 + r)^(-LifeTime[i]))) for i in I) # [EUR/MW-year]

    ## STORAGE
    ## Installed storage energy - [MWh]
    CAPstor_energy = m.ext[:parameters][:CAPstor_energy] = Dict()
    for istor = Istor, row = 1:length(energy_caps.Node)       
        if energy_caps[row,"Node"] == focus_country
            if istor == "Battery"
                CAPstor_energy[istor] = 0
            else
                CAPstor_energy[istor] = energy_caps[row,istor]
            end
        end
    end
    ## Installed storage capacity - [MW]
    CAPstor_power = m.ext[:parameters][:CAPstor_power] = Dict()
    for istor in Istor
        CAPstor_power[istor] = 0
    end
    for istor in Istor, row = 1:length(gen_cap.Node)
        if gen_cap.Node[row] == focus_country
            if gen_cap.Generator_ID[row] == istor
                if gen_cap[row,"Year"] == Year
                    if gen_cap[row,"Climate Year"] == ClimateYear
                        CAPstor_power[istor] = CAPstor_power[istor] + gen_cap[row,"Value"]
                    end
                end
            end
        end
    end
    ## Power-energy factor of storage technologies - [1/h]
    PEstor = m.ext[:parameters][:PEstor] = Dict()
    for istor in Istor
        if istor == "Battery"
            PEstor[istor] = 1/3
            CAPstor_energy[istor] = CAPstor_power[istor]/PEstor[istor]
        elseif CAPstor_energy[istor] == 0
            if istor == "ROR"
                PEstor[istor] = 1
                CAPstor_energy[istor] = CAPstor_power[istor]/PEstor[istor]
            else
                PEstor[istor] = 0
            end
        else
            PEstor[istor] = CAPstor_power[istor]/CAPstor_energy[istor]
        end
    end
    ## Efficiencies of storage technologies - [-]
    m.ext[:parameters][:efficiency_stor] = Dict()
    for istor in Istor, row = 1:length(gen_efficiencies.Generator_ID)
        if gen_efficiencies[row,"Generator_ID"] == istor
            m.ext[:parameters][:efficiency_stor][istor] = gen_efficiencies[row,"efficiency"]
        end
    end
    ## Initial state-of-charge of storage technologies - [MWh]
    m.ext[:parameters][:EnergyInitstor] = Dict()
    m.ext[:parameters][:EnergyFinalstor] = Dict()
    for istor in Istor
        if istor == "ROR"
            m.ext[:parameters][:EnergyInitstor][istor] = 0
            m.ext[:parameters][:EnergyFinalstor][istor] = 0
        else
            m.ext[:parameters][:EnergyInitstor][istor] = CAPstor_energy[istor]/2
            m.ext[:parameters][:EnergyFinalstor][istor] = CAPstor_energy[istor]/2
        end
    end
    #####################################################################################################################################################################

    #####################Parameters direct neighboring countries#########################################################################################################

    ## Variable costs (focus country and direct neighboring countries)
    βcd = m.ext[:parameters][:βcd] = Dict() # [EUR/MWh] (data expressed in EUR/GJ = EUR/GWs -> EUR/GWs * 3600s/h / (1000MW/GW) = EUR/GWs*3.6 = EUR/MWh)
    for idcd = IDcd, fuel = 1:length(fuel_costs.FT)
        if idcd == "CCGT" || idcd == "OCGT"
            if fuel_costs[fuel,"FT"] == "Natural gas"
                m.ext[:parameters][:βcd][idcd] = fuel_costs[fuel,string(Year)] * 3.6
            end
        elseif idcd == "Coal_bio"
            if fuel_costs[fuel,"FT"] == "Biomass"
                m.ext[:parameters][:βcd][idcd] = fuel_costs[fuel,string(Year)] * 3.6
            end
        elseif idcd == "Oil_light"
            if fuel_costs[fuel,"FT"] == "Gasoline"
                m.ext[:parameters][:βcd][idcd] = fuel_costs[fuel,string(Year)] * 3.6
            end
        elseif idcd == "Oil_heavy"
            if fuel_costs[fuel,"FT"] == "HFO"
                m.ext[:parameters][:βcd][idcd] = fuel_costs[fuel,string(Year)] * 3.6
            end
        elseif idcd == "CCGT_bio" || idcd == "OCGT_bio"
            if fuel_costs[fuel,"FT"] == "Biogas"
                m.ext[:parameters][:βcd][idcd] = fuel_costs[fuel,string(Year)] * 3.6
            end
        elseif idcd == "Oil_heavy_bio"
            if fuel_costs[fuel,"FT"] == "Biogasoline"
                m.ext[:parameters][:βcd][idcd] = fuel_costs[fuel,string(Year)] * 3.6
            end
        else 
            if fuel_costs[fuel,"FT"] == idcd
                m.ext[:parameters][:βcd][idcd] = fuel_costs[fuel,string(Year)] * 3.6
            end
        end
    end

    δcd = m.ext[:parameters][:δcd] = Dict() # [ton/MWh] (data expressed in kg/MWh -> kg/MWh / (1000kg/ton) = kg/MWh / 1000 = ton/MWh)
    for idcd = IDcd, gen = 1:length(gen_efficiencies.Generator_ID)
        if gen_efficiencies[gen,"Generator_ID"] == idcd
            m.ext[:parameters][:δcd][idcd] = gen_efficiencies[gen,"emissions(kg/MWh)"] / 1000
        end
    end

    efficiencycd = m.ext[:parameters][:efficiencycd] = Dict() # [-]
    for idcd = IDcd, gen = 1:length(gen_efficiencies.Generator_ID)
        if gen_efficiencies[gen,"Generator_ID"] == idcd
            m.ext[:parameters][:efficiencycd][idcd] = gen_efficiencies[gen,"efficiency"]
        end
    end

    VOMcd = m.ext[:parameters][:VOMcd] = Dict() # [EUR/MWh]
    for idcd = IDcd, gen = 1:length(gen_efficiencies.Generator_ID)
        if gen_efficiencies[gen,"Generator_ID"] == idcd
            m.ext[:parameters][:VOMcd][idcd] = gen_efficiencies[gen,"VOM"]
        end
    end

    m.ext[:parameters][:VCcd] = Dict(idcd => βcd[idcd]/efficiencycd[idcd] + αCO2*δcd[idcd]/efficiencycd[idcd] + VOMcd[idcd] for idcd in IDcd) # Variable costs - [EUR/MWh]

    ## Investment costs (focus country and direct neighboring countries)
    OCcd = m.ext[:parameters][:OCcd] = Dict() # [EUR/MW]
    for i = I, row in 1:length(tech_cost_lifetime.technology)
        if tech_cost_lifetime[row, "technology"] == i
            m.ext[:parameters][:OCcd][i] = tech_cost_lifetime.cost[row]
        end
    end
    for iextra = Iextra
        m.ext[:parameters][:OCcd][iextra] = 0
    end

    LifeTimecd = m.ext[:parameters][:LTcd] = Dict() # [year]
    for i = I, row in 1:length(tech_cost_lifetime.technology)
        if tech_cost_lifetime[row, "technology"] == i
            m.ext[:parameters][:LTcd][i] = tech_cost_lifetime.lifetime[row]
        end
    end
    for iextra = Iextra
        m.ext[:parameters][:LTcd][iextra] = 0
    end

    m.ext[:parameters][:ICcd] = Dict() # [EUR/MW-year]
    for icd in Icd
        if icd ∈ I
            m.ext[:parameters][:ICcd][icd] = (r * OCcd[icd])/((1 - (1 + r)^(-LifeTimecd[icd])))
        else
            m.ext[:parameters][:ICcd][icd] = 0
        end
    end

    ## Fix capacities of neighboring countries to their actual installed capacities - [MW]
    ## Case 1: only fix capacities in neigboring countries based on TYNDP input data
    m.ext[:parameters][:CAPcdonly] = Dict() # [MW]
    ## Case 2: fix capacities in neigboring countries based on TYNDP input data and in focus country based on endogenous model with storage
    m.ext[:parameters][:CAPcdendo] = Dict() # [MW]
    ## Case 3: fix capacities in neigboring countries and focus country based on TYNDP input data
    m.ext[:parameters][:CAPcdtyndp] = Dict() # [MW]
    for country in CDonly, icd in Icd
        m.ext[:parameters][:CAPcdonly][icd,country] = 0
        m.ext[:parameters][:CAPcdendo][icd,country] = 0
        m.ext[:parameters][:CAPcdtyndp][icd,country] = 0
    end
    for country in CDonly, row = 1:length(gen_cap.Node), icd in Icd
        if gen_cap.Node[row] == country
            if gen_cap.Generator_ID[row] == icd
                if gen_cap[row,"Year"] == Year
                    if gen_cap[row,"Climate Year"] == ClimateYear
                        m.ext[:parameters][:CAPcdonly][icd,country] = m.ext[:parameters][:CAPcdonly][icd,country] + gen_cap.Value[row]
                        m.ext[:parameters][:CAPcdendo][icd,country] = m.ext[:parameters][:CAPcdendo][icd,country] + gen_cap.Value[row]
                        m.ext[:parameters][:CAPcdtyndp][icd,country] = m.ext[:parameters][:CAPcdtyndp][icd,country] + gen_cap.Value[row]
                    end
                end
            end
        end
    end
    for row = 1:length(cap_prod_fc_from_endo_model.Technology)
        m.ext[:parameters][:CAPcdendo][cap_prod_fc_from_endo_model[row,"Technology"],focus_country] = cap_prod_fc_from_endo_model[row,"Capacity"]
    end
    for icd in Icd
        m.ext[:parameters][:CAPcdtyndp][icd,focus_country] = 0
    end
    for row = 1:length(gen_cap.Node), icd in Icd
        if gen_cap.Node[row] == focus_country
            if gen_cap.Generator_ID[row] == icd
                if gen_cap[row,"Year"] == Year
                    if gen_cap[row,"Climate Year"] == ClimateYear
                        m.ext[:parameters][:CAPcdtyndp][icd,focus_country] = m.ext[:parameters][:CAPcdtyndp][icd,focus_country] + gen_cap.Value[row]
                    end
                end
            end
        end
    end

    ## Trade of electricity is limited by installed transmission capacities (in both directions) - [MW]
    Fpos = m.ext[:parameters][:Fpos] = Dict() # [MW]
    Fneg = m.ext[:parameters][:Fneg] = Dict() # [MW]
    for line in LinescdVector
        m.ext[:parameters][:Fpos][line] = 0
        m.ext[:parameters][:Fneg][line] = 0
    end
    for row = 1:length(lines.Node1)
        if lines[row,"Year"] == Year
            if lines[row,"Climate Year"] == ClimateYear
                if lines.Parameter[row] == "Export Capacity"
                    if lines[row,"Node/Line"] ∈ LinescdVector
                        m.ext[:parameters][:Fpos][lines[row,"Node/Line"]] = lines.Value[row]
                    end
                elseif lines.Parameter[row] == "Import Capacity"
                    if lines[row,"Node/Line"] ∈ LinescdVector
                        m.ext[:parameters][:Fneg][lines[row,"Node/Line"]] = lines.Value[row]
                    end
                end
            end
        end
    end

    ## Total sum of installed transmission capacity (both for export and import) of focus country - [MW]
    Fpos_sum_fc = m.ext[:parameters][:Fpos_sum_fc] = zeros(24,1) # [MW]
    Fneg_sum_fc = m.ext[:parameters][:Fneg_sum_fc] = zeros(24,1) # [MW]
    for jh = JH, line in LinesfocuscountryVector
        Fpos_sum_fc[jh] = Fpos_sum_fc[jh] + Fpos[line]
        Fneg_sum_fc[jh] = Fneg_sum_fc[jh] + Fneg[line]
    end

    ## Definition T [-]: if positive flow on line implies injection into country, then T = 1; if this implies export from country, then T = -1; if country not connected to line, then T = 0.
    T = m.ext[:parameters][:T] = Dict() # [-]
    for line in LinescdVector, country in CD
        T[country,line] = 0
        if country == Linescd[line][1]
            T[country,line] = -1
        elseif country == Linescd[line][2]
            T[country,line] = 1
        end
    end

    ## STORAGE
    ## Installed storage energy - [MWh]
    CAPstor_energycd = m.ext[:parameters][:CAPstor_energycd] = Dict()
    for cd in CD, istorcd = Istorcd, row = 1:length(energy_caps.Node)
        if cd == focus_country
            if tyndp_iec_sm3 == "no"
                #CAPstor_energycd[istorcd,cd] = 0
                for row = 1:length(capstor_fc_from_endo_model[:,"Storage unit"])
                    if capstor_fc_from_endo_model[row,"Storage unit"] == istorcd
                        CAPstor_energycd[istorcd,cd] = capstor_fc_from_endo_model[row,"Capacity"]
                    end
                end
            elseif tyndp_iec_sm3 == "yes"
                if energy_caps[row,"Node"] == cd
                    if istorcd == "Battery"
                        CAPstor_energycd[istorcd,cd] = 0
                    else
                        CAPstor_energycd[istorcd,cd] = energy_caps[row,istorcd]
                    end
                end
            end
        elseif cd == "DKW1" || cd == "DKE1"
            CAPstor_energycd[istorcd,cd] = 0
        else
            if energy_caps[row,"Node"] == cd
                if istorcd == "Battery"
                    CAPstor_energycd[istorcd,cd] = 0
                else
                    CAPstor_energycd[istorcd,cd] = energy_caps[row,istorcd]
                end
            end
        end
    end
    ## Installed storage capacity - [MW]
    CAPstor_powercd = m.ext[:parameters][:CAPstor_powercd] = Dict()
    for cd in CD, istorcd in Istorcd
        CAPstor_powercd[istorcd,cd] = 0
    end
    for cd in CD, istorcd in Istorcd, row = 1:length(gen_cap.Node)
        if cd == focus_country
            if tyndp_iec_sm3 == "yes"
                if gen_cap.Node[row] == cd
                    if gen_cap.Generator_ID[row] == istorcd
                        if gen_cap[row,"Year"] == Year
                            if gen_cap[row,"Climate Year"] == ClimateYear
                                CAPstor_powercd[istorcd,cd] = CAPstor_powercd[istorcd,cd] + gen_cap[row,"Value"]
                            end
                        end
                    end
                end
            end
        else
            if gen_cap.Node[row] == cd
                if gen_cap.Generator_ID[row] == istorcd
                    if gen_cap[row,"Year"] == Year
                        if gen_cap[row,"Climate Year"] == ClimateYear
                            CAPstor_powercd[istorcd,cd] = CAPstor_powercd[istorcd,cd] + gen_cap[row,"Value"]
                        end
                    end
                end
            end
        end
    end
    ## Power-energy factor of storage technologies - [1/h]
    PEstorcd = m.ext[:parameters][:PEstorcd] = Dict()
    for cd in CD, istorcd in Istorcd
        if cd == focus_country
            if tyndp_iec_sm3 == "no"
                if istorcd == "Battery"
                    PEstorcd[istorcd,cd] = 1/3
                else
                    PEstorcd[istorcd,cd] = 0
                end
            elseif tyndp_iec_sm3 == "yes"
                if istorcd == "Battery"
                    PEstorcd[istorcd,cd] = 1/3
                    CAPstor_energycd[istorcd,cd] = CAPstor_powercd[istorcd,cd]/PEstorcd[istorcd,cd]
                elseif CAPstor_energycd[istorcd,cd] == 0
                    if istorcd == "ROR"
                        PEstorcd[istorcd,cd] = 1
                        CAPstor_energycd[istorcd,cd] = CAPstor_powercd[istorcd,cd]/PEstorcd[istorcd,cd]
                    else
                        PEstorcd[istorcd,cd] = 0
                    end
                else
                    PEstorcd[istorcd,cd] = CAPstor_powercd[istorcd,cd]/CAPstor_energycd[istorcd,cd]
                end
            end
        else
            if istorcd == "Battery"
                PEstorcd[istorcd,cd] = 1/3
                CAPstor_energycd[istorcd,cd] = CAPstor_powercd[istorcd,cd]/PEstorcd[istorcd,cd]
            elseif CAPstor_energycd[istorcd,cd] == 0
                if istorcd == "ROR"
                    PEstorcd[istorcd,cd] = 1
                    CAPstor_energycd[istorcd,cd] = CAPstor_powercd[istorcd,cd]/PEstorcd[istorcd,cd]
                else
                    PEstorcd[istorcd,cd] = 0
                end
            else
                PEstorcd[istorcd,cd] = CAPstor_powercd[istorcd,cd]/CAPstor_energycd[istorcd,cd]
            end
        end
    end
    ## Efficiencies of storage technologies - [-]
    m.ext[:parameters][:efficiency_storcd] = Dict()
    for istorcd in Istorcd, row = 1:length(gen_efficiencies.Generator_ID)
        if gen_efficiencies[row,"Generator_ID"] == istorcd
            m.ext[:parameters][:efficiency_storcd][istorcd] = gen_efficiencies[row,"efficiency"]
        end
    end
    
    #####################IMPACT STORAGE SIZE ADAPTATION##################################################################################################################

    ## Impact of storage size adaptation
    ## SHORT TERM: Battery with extra cap_E in all neighboring countries (UK, FR, DE, NL) based on peak demand (with PE_battery = 1/3 or 1)
    #for cdonly in CDonly
    ##    #PEstorcd["Battery",cdonly] = 1 # If PE = 1/1h
    #    if cdonly == "UK00"
    #        CAPstor_energycd["Battery",cdonly] = CAPstor_energycd["Battery",cdonly] + 26310 * 2 - 1230
    #    elseif cdonly == "DE00"
    #        CAPstor_energycd["Battery",cdonly] = CAPstor_energycd["Battery",cdonly] + 402374 * 2
    #    elseif cdonly == "FR00"
    #        CAPstor_energycd["Battery",cdonly] = CAPstor_energycd["Battery",cdonly] + 105548 * 2
    #    elseif cdonly == "NL00"
    #        CAPstor_energycd["Battery",cdonly] = CAPstor_energycd["Battery",cdonly] + 205912 * 2
    #    end
    #end
    ##PEstorcd["Battery","BE00"] = 1
    ## MID TERM: PS_C with cap_E*1.2 or *1.5 in the neighboring countries UK, FR and DE
    #for cdonly in CDonly
    #    if cdonly == "UK00"
    #        CAPstor_energycd["PS_C",cdonly] = CAPstor_energycd["PS_C",cdonly] * 1.5
    #    elseif cdonly == "DE00"
    #        CAPstor_energycd["PS_C",cdonly] = CAPstor_energycd["PS_C",cdonly] * 1.5
    #    elseif cdonly == "FR00"
    #        CAPstor_energycd["PS_C",cdonly] = CAPstor_energycd["PS_C",cdonly] * 1.5
    #    end
    #end
    ## LONG TERM: Hydrogen with cap_E = 524MW/PE in UK, 857MW/PE in DE, 1000MW/PE in FR and 171MW/PE in NL based on peak demand (with PE = 1/168 or 1/1000, etha = 0.3)
    for cd in CD
        PEstorcd["Hydrogen",cd] = 1/1000
        if cd == focus_country
            if tyndp_iec_sm3 == "yes"
                CAPstor_energycd["Hydrogen",cd] = 0
            elseif tyndp_iec_sm3 == "no"
                for row = 1:length(capstor_fc_from_endo_model[:,"Storage unit"])
                    if capstor_fc_from_endo_model[row,"Storage unit"] == "Hydrogen"
                        CAPstor_energycd["Hydrogen",cd] = capstor_fc_from_endo_model[row,"Capacity"]
                    end
                end
            end
        else
            CAPstor_energycd["Hydrogen",cd] = 0
        #elseif cd == "FR00"
        #    CAPstor_energycd["Hydrogen",cd] = 55879 / 24 * 1000 * 2 #55879 / 24 * 1000 * 2 OR 1000/m.ext[:parameters][:PEstorcd]["Hydrogen",cd]
        #elseif cd == "UK00"
        #    CAPstor_energycd["Hydrogen",cd] = 43038 / 24 * 1000 * 2 #43038 / 24 * 1000 * 2 OR 524/m.ext[:parameters][:PEstorcd]["Hydrogen",cd]
        #elseif cd == "DE00"
        #    CAPstor_energycd["Hydrogen",cd] = 137708 / 24 * 1000 * 2 #137708 / 24 * 1000 * 2 OR 857/m.ext[:parameters][:PEstorcd]["Hydrogen",cd]
        #elseif cd == "NL00"
        #    CAPstor_energycd["Hydrogen",cd] = 66747 / 24 * 1000 * 2 #66747 / 24 * 1000 * 2 OR 171/m.ext[:parameters][:PEstorcd]["Hydrogen",cd]
        end
    end
    m.ext[:parameters][:efficiency_storcd]["Hydrogen"] = 0.62
    m.ext[:parameters][:efficiency_stor]["Hydrogen"] = 0.62
    ## Add hydrogen to set of storage technologies
    m.ext[:sets][:Istorcd] = push!(m.ext[:sets][:Istorcd],"Hydrogen")
    m.ext[:sets][:Istor] = push!(m.ext[:sets][:Istor],"Hydrogen")
    #####################################################################################################################################################################

    ## Initial state-of-charge of storage technologies - [MWh]
    m.ext[:parameters][:EnergyInitstorcd] = Dict()
    m.ext[:parameters][:EnergyFinalstorcd] = Dict()
    for cd in CD, istorcd in Istorcd
        if istorcd == "ROR"
            m.ext[:parameters][:EnergyInitstorcd][istorcd,cd] = 0
            m.ext[:parameters][:EnergyFinalstorcd][istorcd,cd] = 0
        else
            m.ext[:parameters][:EnergyInitstorcd][istorcd,cd] = CAPstor_energycd[istorcd,cd]/2
            m.ext[:parameters][:EnergyFinalstorcd][istorcd,cd] = CAPstor_energycd[istorcd,cd]/2
        end
    end
    #####################################################################################################################################################################

    ######################################################################IEC Submodel 2#################################################################################

    ## Create baseload demand profile for focus country for IEC Submodel 2
    m.ext[:parameters][:DEMANDc] = -Fpos_sum_fc[1] # [MW]
    baseload_levels = m.ext[:parameters][:baseload_levels] = collect(-Fpos_sum_fc[1]+100:100:-Fneg_sum_fc[1]) # Add baseload demand levels (increment steps of 100MW from maximum available export to maximum available import)
    ## Only use three possible baseload demand levels for focus country
    if all_possible_trade_levels == "no"
        m.ext[:parameters][:DEMANDc] = -300 # [MW], '-300' or '-2800' or '-Fpos_sum_fc[1]'
        m.ext[:parameters][:baseload_levels] = [-200,-100,0,100,200,300] # '-200,-100,0,100,200,300' or '-2799,4299,4300' or 'collect(-Fpos_sum_fc[1]+500:500:-Fneg_sum_fc[1])'
    end

    ## Fix state-of-charge of storage technologies in neighboring countries - [MWh]
    ## Case 1: fix state-of-charge of storage technologies in neigboring countries based on TCS-BM
    m.ext[:parameters][:Estor_cdonly_tcs_bm] = Dict() # [MWh]
    ## Case 2: fix state-of-charge of storage technologies in neigboring countries based on TCS-TYNDP
    m.ext[:parameters][:Estor_cdonly_tcs_tyndp] = Dict() # [MWh]
    ## Case 1: fix state-of-charge of storage technologies in neigboring countries based on TCS-ZERO
    m.ext[:parameters][:Estor_cdonly_tcs_zero] = Dict() # [MWh]
    for istorcd in Istorcd
        for cdonly in CDonly
            if istorcd == "Battery"
                m.ext[:parameters][:Estor_cdonly_tcs_bm][istorcd,cdonly] = [SOC_Battery_tcs_bm[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
                m.ext[:parameters][:Estor_cdonly_tcs_tyndp][istorcd,cdonly] = [SOC_Battery_tcs_tyndp[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
                m.ext[:parameters][:Estor_cdonly_tcs_zero][istorcd,cdonly] = [SOC_Battery_tcs_zero[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
            elseif istorcd == "PS_C"
                m.ext[:parameters][:Estor_cdonly_tcs_bm][istorcd,cdonly] = [SOC_PS_C_tcs_bm[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
                m.ext[:parameters][:Estor_cdonly_tcs_tyndp][istorcd,cdonly] = [SOC_PS_C_tcs_tyndp[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
                m.ext[:parameters][:Estor_cdonly_tcs_zero][istorcd,cdonly] = [SOC_PS_C_tcs_zero[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
            elseif istorcd == "PS_O"
                m.ext[:parameters][:Estor_cdonly_tcs_bm][istorcd,cdonly] = [SOC_PS_O_tcs_bm[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
                m.ext[:parameters][:Estor_cdonly_tcs_tyndp][istorcd,cdonly] = [SOC_PS_O_tcs_tyndp[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
                m.ext[:parameters][:Estor_cdonly_tcs_zero][istorcd,cdonly] = [SOC_PS_O_tcs_zero[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
            elseif istorcd == "RES"
                m.ext[:parameters][:Estor_cdonly_tcs_bm][istorcd,cdonly] = [SOC_RES_tcs_bm[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
                m.ext[:parameters][:Estor_cdonly_tcs_tyndp][istorcd,cdonly] = [SOC_RES_tcs_tyndp[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
                m.ext[:parameters][:Estor_cdonly_tcs_zero][istorcd,cdonly] = [SOC_RES_tcs_zero[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
            elseif istorcd == "ROR"
                m.ext[:parameters][:Estor_cdonly_tcs_bm][istorcd,cdonly] = [SOC_ROR_tcs_bm[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
                m.ext[:parameters][:Estor_cdonly_tcs_tyndp][istorcd,cdonly] = [SOC_ROR_tcs_tyndp[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
                m.ext[:parameters][:Estor_cdonly_tcs_zero][istorcd,cdonly] = [SOC_ROR_tcs_zero[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
            elseif istorcd == "Hydrogen"
                m.ext[:parameters][:Estor_cdonly_tcs_bm][istorcd,cdonly] = [SOC_Hydrogen_tcs_bm[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
                m.ext[:parameters][:Estor_cdonly_tcs_tyndp][istorcd,cdonly] = [SOC_Hydrogen_tcs_tyndp[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
                m.ext[:parameters][:Estor_cdonly_tcs_zero][istorcd,cdonly] = [SOC_Hydrogen_tcs_zero[jh + nTimesteps * (jd - 1),cdonly] for jh in JH, jd in JD]
            end
        end
    end
    #####################################################################################################################################################################

    ######################################################################IEC Submodel 1#################################################################################

    if lambda_needed == "yes"
        ## Variable cost of import
        m.ext[:parameters][:VCimp] = Dict(import_price => parse(Float64,import_price) for import_price in Pimp) # [EUR/MWh]
        ## Variable cost of export
        m.ext[:parameters][:VCexp] = Dict(export_price => parse(Float64,export_price) for export_price in Pexp) # [EUR/MWh]
    end

    ## Annualized investment cost of storage units - [EUR/MWh-year]
    ICstor = m.ext[:parameters][:ICstor] = Dict()
    for istorcd in Istorcd
        if istorcd == "Battery"
            ICstor[istorcd] = 25100.97 + 23288.62 * PEstorcd["Battery","BE00"] #32863.84 OR Mongird et al. (2020): 57600 (60$/kWhyr) OR Mongird et al. (2019): 49480 (OC=62$/kWh, T=20yr, r=0.07) (OR Gonzato et al.: OC = 4440 (short-term storage))
        elseif istorcd == "Hydrogen"
            ICstor[istorcd] = 106.84 + 281275.82 * PEstorcd["Hydrogen","BE00"] #11826.67 OR 792.90 from Schlachtberger et al. OR Gonzato et al.: 16.61 (€176/MWh (long-term (P2G) storage) -> 10000) OR Zakeri et al. (2015): 50972.18 (OC=540000EUR/MWh, T=20yr, r=0.07) OR Budischak et al.: 1057.20 (OC=11.2$/kWh, T=20yr, r=0.07)
        else
            ICstor[istorcd] = 0 # Gonzato et al.: 15520 (medium-term storage) ("ROR": 10000 [€/MW])
        end
    end
    #####################################################################################################################################################################

    ## Return model
    return m
end

# call functions
define_sets!(m, tech_cost_lifetime, lines, gen_cap, gen_prod, AF_import_tcs_no_fixing, AF_export_tcs_no_fixing, AF_import_tcs_bm, AF_export_tcs_bm, AF_import_tcs_tyndp, AF_export_tcs_tyndp, AF_import_tcs_zero, AF_export_tcs_zero)
process_time_series_data!(m, load_2025, wind_onshore, wind_offshore, pv, ROR_2012, PS_O_2012, RES_2012, AF_import_tcs_no_fixing, AF_export_tcs_no_fixing, AF_import_tcs_bm, AF_export_tcs_bm, AF_import_tcs_tyndp, AF_export_tcs_tyndp, AF_import_tcs_zero, AF_export_tcs_zero, D_real_tcs_no_fix_no_stor, D_real_tcs_no_fix_stor, D_real_tcs_bm_no_stor, D_real_tcs_bm_stor, D_real_tcs_tyndp_no_stor, D_real_tcs_tyndp_stor, D_real_tcs_zero_no_stor, D_real_tcs_zero_stor)
process_parameters!(m, co2_price, fuel_costs, gen_efficiencies, tech_cost_lifetime, gen_cap, lines, energy_caps, cap_prod_fc_from_endo_model, capstor_fc_from_endo_model, SOC_Battery_tcs_bm, SOC_PS_C_tcs_bm, SOC_PS_O_tcs_bm, SOC_RES_tcs_bm, SOC_ROR_tcs_bm, SOC_Hydrogen_tcs_bm, SOC_Battery_tcs_tyndp, SOC_PS_C_tcs_tyndp, SOC_PS_O_tcs_tyndp, SOC_RES_tcs_tyndp, SOC_ROR_tcs_tyndp, SOC_Hydrogen_tcs_tyndp, SOC_Battery_tcs_zero, SOC_PS_C_tcs_zero, SOC_PS_O_tcs_zero, SOC_RES_tcs_zero, SOC_ROR_tcs_zero, SOC_Hydrogen_tcs_zero)

## Step 3: construct models
## Model discription: focus country (greenfield) - one year - with or without storage in focus country (without cross-border trade)
function build_step_3_single_country_model!(m::Model) # Investment and dispatch optimization in focus country
    storage_included_single_country = "no" # "yes" or "no"
    nTimesteps = 24
    
    ## Clear m.ext entries "variables", "expressions" and "constraints"
    m.ext[:variables] = Dict()
    m.ext[:expressions] = Dict()
    m.ext[:constraints] = Dict()

    ## Extract sets
    I = m.ext[:sets][:I]
    ID = m.ext[:sets][:ID]
    IV = m.ext[:sets][:IV]
    Istor = m.ext[:sets][:Istor]
    IstorRES = m.ext[:sets][:IstorRES]
    IstorROR = m.ext[:sets][:IstorROR]
    JH = m.ext[:sets][:JH]
    JD = m.ext[:sets][:JD]

    ## Extract time series data
    DEMAND = m.ext[:timeseries][:DEMAND] # Demand
    AF = m.ext[:timeseries][:AF] # Avaiability factors
    inflowc = m.ext[:timeseries][:inflowc] # Inflow of storage units

    ## Extract parameters
    VOLL = m.ext[:parameters][:VOLL] # VOLL
    VC = m.ext[:parameters][:VC] # Variable costs
    IC = m.ext[:parameters][:IC] # Investment costs
    CAPstor_energy = m.ext[:parameters][:CAPstor_energy] # Energy content of storage technologies
    PEstor = m.ext[:parameters][:PEstor] # Power-energy ratio of storage technologies
    efficiency_stor = m.ext[:parameters][:efficiency_stor] # Efficiency of storage technologies
    EnergyInitstor = m.ext[:parameters][:EnergyInitstor] # Initial state-of-charge of storage technologies
    EnergyFinalstor = m.ext[:parameters][:EnergyFinalstor] # Final state-of-charge of storage technologies

    ## Create variables
    cap_gen = m.ext[:variables][:cap_gen] = @variable(m, [i=I], lower_bound=0, base_name="capacity_generation") # [MW]
    gen = m.ext[:variables][:gen] = @variable(m, [i=I,jh=JH,jd=JD], lower_bound=0, base_name="generation") # [MW]
    ens =  m.ext[:variables][:ens] = @variable(m, [jh=JH,jd=JD], lower_bound=0, base_name="load_shedding") # [MW]
    ch_stor =  m.ext[:variables][:ch_stor] = @variable(m, [istor=Istor,jh=JH,jd=JD], lower_bound=0, base_name="charging_power") # [MW]
    dc_stor =  m.ext[:variables][:dc_stor] = @variable(m, [istor=Istor,jh=JH,jd=JD], lower_bound=0, base_name="discharging_power") # [MW]
    e_stor =  m.ext[:variables][:e_stor] = @variable(m, [istor=Istor,jh=JH,jd=JD], lower_bound=0, base_name="energy_content") # [MWh]
    #cap_stor = m.ext[:variables][:cap_stor] = @variable(m, [istor=I_STOR], lower_bound=0, base_name="capacity_storage") # [MWh]

    ## Create affine expressions (= linear combinations of variables) - curt: [MW]
    curt = m.ext[:expressions][:curt] = @expression(m, [iv=IV,jh=JH,jd=JD],
        AF[iv][jh,jd] * cap_gen[iv] - gen[iv,jh,jd]
    )

    ## Formulate objective 1a
    m.ext[:objective] = @objective(m, Min,
        + sum(IC[i] * cap_gen[i] for i in I)
        + sum(VC[i] * gen[i,jh,jd] for i in ID, jh in JH, jd in JD)
        + sum(ens[jh,jd] * VOLL for jh in JH, jd in JD)
        #+ sum(ICstor[istor] * cap_stor[istor] for istor in Istor)
    )

    ## Formulate constraints
    m.ext[:constraints][:conSingleCountry1b] = @constraint(m, [jh=JH,jd=JD],
        sum(gen[i,jh,jd] for i in I) + ens[jh,jd] + sum(dc_stor[istor,jh,jd]-ch_stor[istor,jh,jd] for istor in Istor) == DEMAND[jh,jd]
    )
    m.ext[:constraints][:conSingleCountry1c1] = @constraint(m, [iv=IV,jh=JH,jd=JD],
        gen[iv,jh,jd] <= AF[iv][jh,jd] * cap_gen[iv]
    )
    m.ext[:constraints][:conSingleCountry1c2] = @constraint(m, [id=ID,jh=JH,jd=JD],
        gen[id,jh,jd] <= cap_gen[id]
    )
    ## Removing RES: add following constraint
    #m.ext[:constraints][:conSingleCountryNORES] = @constraint(m, [iv=IV],
    #    cap_gen[iv] <= 0
    #)
    ## Storage constraints
    if storage_included_single_country == "yes"
        m.ext[:constraints][:conSingleCountry1d] = @constraint(m, [istor=Istor,jh=JH,jd=JD],
            ch_stor[istor,jh,jd] <= PEstor[istor] * CAPstor_energy[istor]
        )
        m.ext[:constraints][:conSingleCountry1e] = @constraint(m, [istor=Istor,jh=JH,jd=JD],
            dc_stor[istor,jh,jd] <= PEstor[istor] * CAPstor_energy[istor]
        )
        m.ext[:constraints][:conSingleCountry1f] = @constraint(m, [istor=Istor,jh=JH,jd=JD],
            e_stor[istor,jh,jd] <= CAPstor_energy[istor]
        )
        m.ext[:constraints][:conSingleCountry1g1] = @constraint(m, [istor=Istor,jh=[JH[1]],jd=[JD[1]]], # Hour 1 of day 1 (to plot value)
            e_stor[istor,jh,jd] == EnergyInitstor[istor]
        )
        m.ext[:constraints][:conSingleCountry1g2] = @constraint(m, [istor=Istor,jh=[JH[1]],jd=[JD[1]]], # Hour 2 of day 1 
            e_stor[istor,jh+1,jd] == e_stor[istor,jh,jd] + inflowc[istor][jh + nTimesteps * (jd - 1)] + efficiency_stor[istor]*ch_stor[istor,jh,jd] - dc_stor[istor,jh,jd]/efficiency_stor[istor]
        )
        m.ext[:constraints][:conSingleCountry1g3] = @constraint(m, [istor=Istor,jhend=JH[2]:JH[end-1],jd=[JD[1]]], # Hour 3 until hour 24 of day 1
            e_stor[istor,jhend+1,jd] == e_stor[istor,jhend,jd] + inflowc[istor][jhend + nTimesteps * (jd - 1)] + efficiency_stor[istor]*ch_stor[istor,jhend,jd] - dc_stor[istor,jhend,jd]/efficiency_stor[istor]
        )
        m.ext[:constraints][:conSingleCountry1g4] = @constraint(m, [istor=Istor,jh=[JH[1]],jdbegin=JD[1]:JD[end-1]], # Hour 1 of next day equals hour 24 of day itself
            e_stor[istor,jh,jdbegin+1] == e_stor[istor,last(JH),jdbegin] + inflowc[istor][last(JH) + nTimesteps * (jdbegin - 1)] + efficiency_stor[istor]*ch_stor[istor,last(JH),jdbegin] - dc_stor[istor,last(JH),jdbegin]/efficiency_stor[istor]
        )
        m.ext[:constraints][:conSingleCountry1g5] = @constraint(m, [istor=Istor,jhbegin=JH[1]:JH[end-1],jdmiddle=JD[2]:JD[end-1]], # Hour 2 until hour 24 of day 2 until day 364
            e_stor[istor,jhbegin+1,jdmiddle] == e_stor[istor,jhbegin,jdmiddle] + inflowc[istor][jhbegin + nTimesteps * (jdmiddle - 1)] + efficiency_stor[istor]*ch_stor[istor,jhbegin,jdmiddle] - dc_stor[istor,jhbegin,jdmiddle]/efficiency_stor[istor]
        )
        m.ext[:constraints][:conSingleCountry1g6] = @constraint(m, [istor=Istor,jhbegin=JH[1]:JH[end-2],jd=[last(JD)]], # Hour 2 until hour 23 of day 365
            e_stor[istor,jhbegin+1,jd] == e_stor[istor,jhbegin,jd] + inflowc[istor][jhbegin + nTimesteps * (jd - 1)] + efficiency_stor[istor]*ch_stor[istor,jhbegin,jd] - dc_stor[istor,jhbegin,jd]/efficiency_stor[istor]
        )
        m.ext[:constraints][:conSingleCountry1g7] = @constraint(m, [istor=Istor,jh=[JH[end-1]],jd=[last(JD)]], # Hour 24 of day 365
            e_stor[istor,jh+1,jd] == e_stor[istor,jh,jd] + inflowc[istor][jh + nTimesteps * (jd - 1)] + efficiency_stor[istor]*ch_stor[istor,jh,jd] - dc_stor[istor,jh,jd]/efficiency_stor[istor]
        )
        m.ext[:constraints][:conSingleCountry1g8] = @constraint(m, [istor=Istor,jh=[last(JH)],jd=[last(JD)]], # Hour 24 of day 365 (to plot value)
            e_stor[istor,jh,jd] == EnergyFinalstor[istor]
        )
        ## RES no charging
        m.ext[:constraints][:conSingleCountry1d_NoChargeRES] = @constraint(m, [istorres=IstorRES,jh=JH,jd=JD],
            ch_stor[istorres,jh,jd] <= 0
        )
        ## ROR no charging
        m.ext[:constraints][:conSingleCountry1d_NoChargeROR] = @constraint(m, [istorror=IstorROR,jh=JH,jd=JD],
            ch_stor[istorror,jh,jd] <= 0
        )
        ## ROR no SOC (only if 'cap_E(ROR)=0')
        m.ext[:constraints][:conSingleCountry1f_NoSOCROR] = @constraint(m, [istorror=IstorROR,jh=JH,jd=JD],
            e_stor[istorror,jh,jd] <= 0
        )
    elseif storage_included_single_country == "no" # Removing storage (no constraints '1g')
        m.ext[:constraints][:conSingleCountryNOSTOR1] = @constraint(m, [istor=Istor,jh=JH,jd=JD],
            ch_stor[istor,jh,jd] <= 0
        )
        m.ext[:constraints][:conSingleCountryNOSTOR2] = @constraint(m, [istor=Istor,jh=JH,jd=JD],
            dc_stor[istor,jh,jd] <= 0
        )
        m.ext[:constraints][:conSingleCountryNOSTOR3] = @constraint(m, [istor=Istor,jh=JH,jd=JD],
            e_stor[istor,jh,jd] <= 0
        )
    end
    m.ext[:constraints][:conSingleCountry1j] = @constraint(m, [jh=JH,jd=JD],
        ens[jh,jd] <= DEMAND[jh,jd]
    )
    return m
end

## Model discription: focus country (greenfield) and neighboring countries (brownfield: based on TYNDP) - one year - with or without storage in neighboring countries
function build_endogenous_direct_countries_model!(m::Model) # Investment and dispatch optimization in focus country, dispatch optimization in neighboring countries
    #focus_country = "BE00"
    storage_included = "yes" # "yes" or "no"
    nTimesteps = 24

    ## Clear m.ext entries "variables", "expressions" and "constraints"
    m.ext[:variables] = Dict()
    m.ext[:expressions] = Dict()
    m.ext[:constraints] = Dict()

    ## Extract sets
    Icd = m.ext[:sets][:Icd]
    IDcd = m.ext[:sets][:IDcd]
    IVcd = m.ext[:sets][:IVcd]
    Iextra = m.ext[:sets][:Iextra]
    Istorcd = m.ext[:sets][:Istorcd]
    IstorcdRES = m.ext[:sets][:IstorcdRES]
    IstorcdROR = m.ext[:sets][:IstorcdROR]
    IstorNO = m.ext[:sets][:IstorNO]
    JH = m.ext[:sets][:JH]
    JD = m.ext[:sets][:JD]
    C = m.ext[:sets][:C]
    CD = m.ext[:sets][:CD]
    CDonly = m.ext[:sets][:CDonly]
    LinescdVector = m.ext[:sets][:LinescdVector]

    ## Extract time series data
    DEMANDcd = m.ext[:timeseries][:DEMANDcd] # Demand
    AFcd = m.ext[:timeseries][:AFcd] # Avaiability factors
    inflow = m.ext[:timeseries][:inflow]

    ## Extract parameters
    VOLL = m.ext[:parameters][:VOLL] # VOLL
    VCcd = m.ext[:parameters][:VCcd] # Variable costs
    ICcd = m.ext[:parameters][:ICcd] # Investment costs of generation units
    ICstor = m.ext[:parameters][:ICstor] # Investment costs of storage units
    CAPcdonly = m.ext[:parameters][:CAPcdonly] # Capacities in non-focus countries are fixed
    Fpos = m.ext[:parameters][:Fpos]
    Fneg = m.ext[:parameters][:Fneg]
    T = m.ext[:parameters][:T] # T = 1 if positive flow on line l implies inejction into country, -1 if flow exiting country and 0 is country not connected to line
    PHI = m.ext[:parameters][:PHI]
    CAPstor_energycd = m.ext[:parameters][:CAPstor_energycd] # Energy content of storage technologies of neighboring countries
    PEstorcd = m.ext[:parameters][:PEstorcd] # Power-energy ratio of storage technologies of neighboring countries    
    efficiency_storcd = m.ext[:parameters][:efficiency_storcd] # Efficiency of storage technologies
    EnergyInitstorcd = m.ext[:parameters][:EnergyInitstorcd] # Initial state-of-charge of storage technologies of neighboring countries
    EnergyFinalstorcd = m.ext[:parameters][:EnergyFinalstorcd] # Final state-of-charge of storage technologies of neighboring countries

    ## Create variables
    cap_gen = m.ext[:variables][:cap_gen] = @variable(m, [icd=Icd,cd=CD], lower_bound=0, base_name="capacity_generation") # [MW]
    cap_stor = m.ext[:variables][:cap_stor] = @variable(m, [istorcd=Istorcd,cd=CD], lower_bound=0, base_name="capacity_storage") # [MWh]
    gen = m.ext[:variables][:gen] = @variable(m, [icd=Icd,jh=JH,jd=JD,cd=CD], lower_bound=0, base_name="generation") # [MW]
    ens =  m.ext[:variables][:ens] = @variable(m, [jh=JH,jd=JD,cd=CD], lower_bound=0, base_name="load_shedding") # [MW]
    ch_stor =  m.ext[:variables][:ch_stor] = @variable(m, [istorcd=Istorcd,jh=JH,jd=JD,cd=CD], lower_bound=0, base_name="charging_power") # [MW]
    dc_stor =  m.ext[:variables][:dc_stor] = @variable(m, [istorcd=Istorcd,jh=JH,jd=JD,cd=CD], lower_bound=0, base_name="discharging_power") # [MW]
    e_stor =  m.ext[:variables][:e_stor] = @variable(m, [istorcd=Istorcd,jh=JH,jd=JD,cd=CD], lower_bound=0, base_name="energy_content") # [MWh]
    flow = m.ext[:variables][:flow] = @variable(m, [l=LinescdVector,jh=JH,jd=JD], base_name="line_flow") # [MW]
    Tflow_abs = m.ext[:variables][:Tflow_abs] = @variable(m, [cd=CD,l=LinescdVector,jh=JH,jd=JD], lower_bound=0, base_name="T_times_line_flow_absolute_value") # [MW]

    ## Create affine expressions (= linear combinations of variables) - curt: [MW]
    curt = m.ext[:expressions][:curt] = @expression(m, [ivcd=IVcd,jh=JH,jd=JD,cd=CD],
        AFcd[ivcd,cd][jh,jd] * cap_gen[ivcd,cd] - gen[ivcd,jh,jd,cd]
    )

    ## Formulate objective 1a
    m.ext[:objective] = @objective(m, Min,
        + sum(ICcd[icd] * cap_gen[icd,c] for icd in Icd, c in C)
        + sum(ICstor[istorcd] * cap_stor[istorcd,c] for istorcd in Istorcd, c in C)
        + sum(VCcd[idcd] * gen[idcd,jh,jd,cd] for idcd in IDcd, jh in JH, jd in JD, cd in CD)
        + sum(ens[jh,jd,cd] * VOLL for jh in JH, jd in JD, cd in CD)
        + sum(PHI * Tflow_abs[cd,l,jh,jd] for l in LinescdVector, jh in JH, jd in JD, cd in CD)
    )

    ## Formulate constraints
    m.ext[:constraints][:conEndogenous1b] = @constraint(m, [jh=JH,jd=JD,cd=CD],
        sum(gen[icd,jh,jd,cd] for icd in Icd) + ens[jh,jd,cd] + sum(T[cd,l]*flow[l,jh,jd] for l in LinescdVector) + sum(dc_stor[istorcd,jh,jd,cd]-ch_stor[istorcd,jh,jd,cd] for istorcd in Istorcd) == DEMANDcd[cd][jh,jd]
    )
    m.ext[:constraints][:conEndogenous1c1] = @constraint(m, [ivcd=IVcd,jh=JH,jd=JD,cd=CD],
        gen[ivcd,jh,jd,cd] <= AFcd[ivcd,cd][jh,jd] * cap_gen[ivcd,cd]
    )
    m.ext[:constraints][:conEndogenous1c2] = @constraint(m, [idcd=IDcd,jh=JH,jd=JD,cd=CD],
        gen[idcd,jh,jd,cd] <= cap_gen[idcd,cd]
    )
    m.ext[:constraints][:conEndogenous1j] = @constraint(m, [jh=JH,jd=JD,cd=CD],
        ens[jh,jd,cd] <= DEMANDcd[cd][jh,jd]
    )
    ## Keeping RES
    m.ext[:constraints][:conEndogenous1l1] = @constraint(m, [icd=Icd,cdonly=CDonly],
        cap_gen[icd,cdonly] == CAPcdonly[icd,cdonly]
    )
    ## Removing RES: remove '#' of line codes of two following constraints and add '#' in line codes of previous constraint
    #m.ext[:constraints][:conEndogenous1l1] = @constraint(m, [idcd=IDcd,cdonly=CDonly],
    #    cap_gen[idcd,cdonly] == CAPcdonly[idcd,cdonly]
    #)
    #m.ext[:constraints][:conSingleCountryNORES] = @constraint(m, [ivcd=IVcd,cd=CD],
    #    cap_gen[ivcd,cd] <= 0
    #)
    ## Only five main technologies installed in focus country
    m.ext[:constraints][:conEndogenous1l2] = @constraint(m, [iextra=Iextra,c=C],
        cap_gen[iextra,c] <= 0
    )
    ## Flow constraints
    m.ext[:constraints][:conEndogenous2e] = @constraint(m, [jh=JH,jd=JD,l=LinescdVector],
        Fneg[l] <= flow[l,jh,jd] <= Fpos[l]
    )
    m.ext[:constraints][:conEndogenous2e1] = @constraint(m, [cd=CD,l=LinescdVector,jh=JH,jd=JD],
        Tflow_abs[cd,l,jh,jd] >= T[cd,l]*flow[l,jh,jd]
    )
    m.ext[:constraints][:conEndogenous2e2] = @constraint(m, [cd=CD,l=LinescdVector,jh=JH,jd=JD],
        Tflow_abs[cd,l,jh,jd] >= -T[cd,l]*flow[l,jh,jd]
    )
    ## Storage constraints
    if storage_included == "yes"
        m.ext[:constraints][:conEndogenous1d] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,cd=CD],
            ch_stor[istorcd,jh,jd,cd] <= PEstorcd[istorcd,cd] * cap_stor[istorcd,cd] #CAPstor_energycd[istorcd,cd]
        )
        m.ext[:constraints][:conEndogenous1e] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,cd=CD],
            dc_stor[istorcd,jh,jd,cd] <= PEstorcd[istorcd,cd] * cap_stor[istorcd,cd] #CAPstor_energycd[istorcd,cd]
        )
        m.ext[:constraints][:conEndogenous1f] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,cd=CD],
            e_stor[istorcd,jh,jd,cd] <= cap_stor[istorcd,cd] #CAPstor_energycd[istorcd,cd]
        )
        m.ext[:constraints][:conEndogenous1g1conly] = @constraint(m, [istorcd=Istorcd,jh=[JH[1]],jd=[JD[1]],c=C], # Hour 1 of day 1 (to plot value)
            e_stor[istorcd,jh,jd,c] == 0 #infeasible if 'cap_stor[istorcd,cd]/2' #EnergyInitstorcd[istorcd,cd]
        )
        m.ext[:constraints][:conEndogenous1g1cdonly] = @constraint(m, [istorcd=Istorcd,jh=[JH[1]],jd=[JD[1]],cdonly=CDonly], # Hour 1 of day 1 (to plot value)
            e_stor[istorcd,jh,jd,cdonly] == EnergyInitstorcd[istorcd,cdonly]
        )
        m.ext[:constraints][:conEndogenous1g2] = @constraint(m, [istorcd=Istorcd,jh=[JH[1]],jd=[JD[1]],cd=CD], # Hour 2 of day 1 
            e_stor[istorcd,jh+1,jd,cd] == e_stor[istorcd,jh,jd,cd] + inflow[cd,istorcd][jh + nTimesteps * (jd - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,jh,jd,cd] - dc_stor[istorcd,jh,jd,cd]/efficiency_storcd[istorcd]
        )
        m.ext[:constraints][:conEndogenous1g3] = @constraint(m, [istorcd=Istorcd,jhend=JH[2]:JH[end-1],jd=[JD[1]],cd=CD], # Hour 3 until hour 24 of day 1
            e_stor[istorcd,jhend+1,jd,cd] == e_stor[istorcd,jhend,jd,cd] + inflow[cd,istorcd][jhend + nTimesteps * (jd - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,jhend,jd,cd] - dc_stor[istorcd,jhend,jd,cd]/efficiency_storcd[istorcd]
        )    
        m.ext[:constraints][:conEndogenous1g4] = @constraint(m, [istorcd=Istorcd,jh=[JH[1]],jdbegin=JD[1]:JD[end-1],cd=CD], # Hour 1 of next day equals hour 24 of day itself
            e_stor[istorcd,jh,jdbegin+1,cd] == e_stor[istorcd,last(JH),jdbegin,cd] + inflow[cd,istorcd][last(JH) + nTimesteps * (jdbegin - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,last(JH),jdbegin,cd] - dc_stor[istorcd,last(JH),jdbegin,cd]/efficiency_storcd[istorcd]
        )
        m.ext[:constraints][:conEndogenous1g5] = @constraint(m, [istorcd=Istorcd,jhbegin=JH[1]:JH[end-1],jdmiddle=JD[2]:JD[end-1],cd=CD], # Hour 2 until hour 24 of day 2 until day 364
            e_stor[istorcd,jhbegin+1,jdmiddle,cd] == e_stor[istorcd,jhbegin,jdmiddle,cd] + inflow[cd,istorcd][jhbegin + nTimesteps * (jdmiddle - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,jhbegin,jdmiddle,cd] - dc_stor[istorcd,jhbegin,jdmiddle,cd]/efficiency_storcd[istorcd]
        )
        m.ext[:constraints][:conEndogenous1g6] = @constraint(m, [istorcd=Istorcd,jhbegin=JH[1]:JH[end-2],jd=[last(JD)],cd=CD], # Hour 2 until hour 23 of day 365
            e_stor[istorcd,jhbegin+1,jd,cd] == e_stor[istorcd,jhbegin,jd,cd] + inflow[cd,istorcd][jhbegin + nTimesteps * (jd - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,jhbegin,jd,cd] - dc_stor[istorcd,jhbegin,jd,cd]/efficiency_storcd[istorcd]
        )
        m.ext[:constraints][:conEndogenous1g7] = @constraint(m, [istorcd=Istorcd,jh=[JH[end-1]],jd=[last(JD)],cd=CD], # Hour 24 of day 365
            e_stor[istorcd,jh+1,jd,cd] == e_stor[istorcd,jh,jd,cd] + inflow[cd,istorcd][jh + nTimesteps * (jd - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,jh,jd,cd] - dc_stor[istorcd,jh,jd,cd]/efficiency_storcd[istorcd]
        )
        m.ext[:constraints][:conEndogenous1g8conly] = @constraint(m, [istorcd=Istorcd,jh=[last(JH)],jd=[last(JD)],c=C], # Hour 24 of day 365 (to plot value)
            e_stor[istorcd,jh,jd,c] == 0 #infeasible if 'cap_stor[istorcd,cd]/2' #EnergyFinalstorcd[istorcd,cd]
        )
        m.ext[:constraints][:conEndogenous1g8cdonly] = @constraint(m, [istorcd=Istorcd,jh=[last(JH)],jd=[last(JD)],cdonly=CDonly], # Hour 24 of day 365 (to plot value)
            e_stor[istorcd,jh,jd,cdonly] == EnergyFinalstorcd[istorcd,cdonly]
        )
        ## RES no charging
        m.ext[:constraints][:conEndogenous1d_NoChargeRES] = @constraint(m, [istorcdres=IstorcdRES,jh=JH,jd=JD,cd=CD],
            ch_stor[istorcdres,jh,jd,cd] <= 0
        )
        ## ROR no charging
        m.ext[:constraints][:conEndogenous1d_NoChargeROR] = @constraint(m, [istorcdror=IstorcdROR,jh=JH,jd=JD,cd=CD],
            ch_stor[istorcdror,jh,jd,cd] <= 0
        )
        ## ROR no SOC (only for countries with 'cap_E(ROR)=0')
        m.ext[:constraints][:conEndogenous1f_NoSOCROR] = @constraint(m, [istorcdror=IstorcdROR,jh=JH,jd=JD,cd=CD],
            e_stor[istorcdror,jh,jd,cd] <= 0
        )
        ## Fixed capacities in neighboring countries
        m.ext[:constraints][:conEndogenous1dfix] = @constraint(m, [istorcd=Istorcd,cdonly=CDonly],
            cap_stor[istorcd,cdonly] == CAPstor_energycd[istorcd,cdonly]
        )
        ## Assume Belgium is not allowed to invest in PS_C, PS_O, ROR and RES (only investments in Battery and Hydrogen possible)
        m.ext[:constraints][:conEndogenousNOTallSTOR] = @constraint(m, [istorno=IstorNO,c=C],
            cap_stor[istorno,c] <= 0
        )
    elseif storage_included == "no" # Removing storage (no constraints '1g')
        m.ext[:constraints][:conEndogenousNOSTOR1] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,cd=CD],
            ch_stor[istorcd,jh,jd,cd] <= 0
        )
        m.ext[:constraints][:conEndogenousNOSTOR2] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,cd=CD],
            dc_stor[istorcd,jh,jd,cd] <= 0
        )
        m.ext[:constraints][:conEndogenousNOSTOR3] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,cd=CD],
            e_stor[istorcd,jh,jd,cd] <= 0
        )
        m.ext[:constraints][:conEndogenousNOSTOR] = @constraint(m, [istorcd=Istorcd,cd=CD],
            cap_stor[istorcd,cd] <= 0
        )
    end
    return m
end

## Model discription: focus country (brownfield: based on endogenous model, TYNDP input data or assume no capacities/demand) and neighboring countries (brownfield: based on TYNDP) - one year
function build_IEC_submodel_3!(m::Model) # Dispatch optimization in all considered countries
    #focus_country = "BE00"
    nTimesteps = 24
    tyndp_iec_sm3 = "no" # "no" or "yes" -> ONLY YES IF "tcs_zero_iec_sm3 = "no""!
    tcs_zero_iec_sm3 = "no" # "no" or "yes" -> ONLY YES IF "tyndp_iec_sm3 = "no""!

    ## Clear m.ext entries "variables", "expressions" and "constraints"
    m.ext[:variables] = Dict()
    m.ext[:expressions] = Dict()
    m.ext[:constraints] = Dict()

    ## Extract sets
    Icd = m.ext[:sets][:Icd]
    IDcd = m.ext[:sets][:IDcd]
    IVcd = m.ext[:sets][:IVcd]
    Iextra = m.ext[:sets][:Iextra]
    Istorcd = m.ext[:sets][:Istorcd]
    IstorcdRES = m.ext[:sets][:IstorcdRES]
    IstorcdROR = m.ext[:sets][:IstorcdROR]
    JH = m.ext[:sets][:JH]
    JD = m.ext[:sets][:JD]
    C = m.ext[:sets][:C]
    CD = m.ext[:sets][:CD]
    CDonly = m.ext[:sets][:CDonly]
    LinescdVector = m.ext[:sets][:LinescdVector]

    ## Extract time series data
    DEMANDcd = m.ext[:timeseries][:DEMANDcd] # Demand
    AFcd = m.ext[:timeseries][:AFcd] # Avaiability factors
    inflow = m.ext[:timeseries][:inflow]

    ## Extract parameters
    VOLL = m.ext[:parameters][:VOLL] # VOLL
    VCcd = m.ext[:parameters][:VCcd] # Variable costs
    if tyndp_iec_sm3 == "no"
        CAPcd = m.ext[:parameters][:CAPcdendo]
    elseif tyndp_iec_sm3 == "yes"
        CAPcd = m.ext[:parameters][:CAPcdtyndp]
    end
    Fpos = m.ext[:parameters][:Fpos]
    Fneg = m.ext[:parameters][:Fneg]
    T = m.ext[:parameters][:T] # T = 1 if positive flow on line l implies inejction into country, -1 if flow exiting country and 0 is country not connected to line
    PHI = m.ext[:parameters][:PHI]
    CAPstor_energycd = m.ext[:parameters][:CAPstor_energycd] # Energy content of storage technologies of neighboring countries
    PEstorcd = m.ext[:parameters][:PEstorcd] # Power-energy ratio of storage technologies of neighboring countries
    efficiency_storcd = m.ext[:parameters][:efficiency_storcd] # Efficiency of storage technologies
    EnergyInitstorcd = m.ext[:parameters][:EnergyInitstorcd] # Initial state-of-charge of storage technologies of neighboring countries
    EnergyFinalstorcd = m.ext[:parameters][:EnergyFinalstorcd] # Final state-of-charge of storage technologies of neighboring countries

    ## Create variables
    gen = m.ext[:variables][:gen] = @variable(m, [icd=Icd,jh=JH,jd=JD,cd=CD], lower_bound=0, base_name="generation") # [MW]
    ens =  m.ext[:variables][:ens] = @variable(m, [jh=JH,jd=JD,cd=CD], lower_bound=0, base_name="load_shedding") # [MW]
    ch_stor =  m.ext[:variables][:ch_stor] = @variable(m, [istorcd=Istorcd,jh=JH,jd=JD,cd=CD], lower_bound=0, base_name="charging_power") # [MW]
    dc_stor =  m.ext[:variables][:dc_stor] = @variable(m, [istorcd=Istorcd,jh=JH,jd=JD,cd=CD], lower_bound=0, base_name="discharging_power") # [MW]
    e_stor =  m.ext[:variables][:e_stor] = @variable(m, [istorcd=Istorcd,jh=JH,jd=JD,cd=CD], lower_bound=0, base_name="energy_content") # [MWh]
    flow = m.ext[:variables][:flow] = @variable(m, [l=LinescdVector,jh=JH,jd=JD], base_name="line_flow") # [MW]
    Tflow_abs = m.ext[:variables][:Tflow_abs] = @variable(m, [cd=CD,l=LinescdVector,jh=JH,jd=JD], lower_bound=0, base_name="T_times_line_flow_absolute_value") # [MW]

    ## Create affine expressions (= linear combinations of variables) - curt: [MW]
    curt = m.ext[:expressions][:curt] = @expression(m, [ivcd=IVcd,jh=JH,jd=JD,cd=CD],
        AFcd[ivcd,cd][jh,jd] * CAPcd[ivcd,cd] - gen[ivcd,jh,jd,cd]
    )

    ## Formulate objective 1a
    m.ext[:objective] = @objective(m, Min,
        + sum(VCcd[idcd] * gen[idcd,jh,jd,cd] for idcd in IDcd, jh in JH, jd in JD, cd in CD)
        + sum(ens[jh,jd,cd] * VOLL for jh in JH, jd in JD, cd in CD)
        + sum(PHI * Tflow_abs[cd,l,jh,jd] for l in LinescdVector, jh in JH, jd in JD, cd in CD)
    )

    ## Formulate constraints
    m.ext[:constraints][:conIECSubmodel3b] = @constraint(m, [jh=JH,jd=JD,cd=CD],
        sum(gen[icd,jh,jd,cd] for icd in Icd) + ens[jh,jd,cd] + sum(T[cd,l]*flow[l,jh,jd] for l in LinescdVector) + sum(dc_stor[istorcd,jh,jd,cd]-ch_stor[istorcd,jh,jd,cd] for istorcd in Istorcd) == DEMANDcd[cd][jh,jd]
    )
    m.ext[:constraints][:conIECSubmodel3c1] = @constraint(m, [ivcd=IVcd,jh=JH,jd=JD,cd=CD],
        gen[ivcd,jh,jd,cd] <= AFcd[ivcd,cd][jh,jd] * CAPcd[ivcd,cd]
    )
    m.ext[:constraints][:conIECSubmodel3c2] = @constraint(m, [idcd=IDcd,jh=JH,jd=JD,cd=CD],
        gen[idcd,jh,jd,cd] <= CAPcd[idcd,cd]
    )
    m.ext[:constraints][:conIECSubmodel3i] = @constraint(m, [jh=JH,jd=JD,cd=CD],
        ens[jh,jd,cd] <= DEMANDcd[cd][jh,jd]
    )
    ## No generation, charge, discharge, soc and load shedding in focus country when using the TCS-ZERO model (ls is equal to zero since demand is zero)
    if tcs_zero_iec_sm3 == "yes"
        m.ext[:constraints][:conIECSubmodel3cZERONETIMPORT] = @constraint(m, [icd=Icd,jh=JH,jd=JD,c=C], # Not use the installed capacities from endo model
            gen[icd,jh,jd,c] <= 0
        )
        m.ext[:constraints][:conIECSubmodel3dZERONETIMPORT] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,c=C], # Not use the installed capacities from endo model
            ch_stor[istorcd,jh,jd,c] <= 0
        )
        m.ext[:constraints][:conIECSubmodel3eZERONETIMPORT] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,c=C], # Not use the installed capacities from endo model
            dc_stor[istorcd,jh,jd,c] <= 0
        )
        m.ext[:constraints][:conIECSubmodel3fZERONETIMPORT] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,c=C], # Not use the installed capacities from endo model
            e_stor[istorcd,jh,jd,c] <= 0
        )
    end
    ## Flow constraints
    m.ext[:constraints][:conIECSubmodel3h1] = @constraint(m, [jh=JH,jd=JD,l=LinescdVector],
        Fneg[l] <= flow[l,jh,jd] <= Fpos[l]
    )
    m.ext[:constraints][:conIECSubmodel3h2] = @constraint(m, [cd=CD,l=LinescdVector,jh=JH,jd=JD],
        Tflow_abs[cd,l,jh,jd] >= T[cd,l]*flow[l,jh,jd]
    )
    m.ext[:constraints][:conIECSubmodel3h3] = @constraint(m, [cd=CD,l=LinescdVector,jh=JH,jd=JD],
        Tflow_abs[cd,l,jh,jd] >= -T[cd,l]*flow[l,jh,jd]
    )
    ## Storage constraints
    m.ext[:constraints][:conIECSubmodel3d] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,cd=CD],
        ch_stor[istorcd,jh,jd,cd] <= PEstorcd[istorcd,cd] * CAPstor_energycd[istorcd,cd]
    )
    m.ext[:constraints][:conIECSubmodel3e] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,cd=CD],
        dc_stor[istorcd,jh,jd,cd] <= PEstorcd[istorcd,cd] * CAPstor_energycd[istorcd,cd]
    )
    m.ext[:constraints][:conIECSubmodel3f] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,cd=CD],
        e_stor[istorcd,jh,jd,cd] <= CAPstor_energycd[istorcd,cd]
    )
    if tcs_zero_iec_sm3 == "yes"
        m.ext[:constraints][:conIECSubmodel3g1conlyzero] = @constraint(m, [istorcd=Istorcd,jh=[JH[1]],jd=[JD[1]],c=C], # Hour 1 of day 1 (to plot value)
            e_stor[istorcd,jh,jd,c] == 0
        )
    elseif tcs_zero_iec_sm3 == "no"
        m.ext[:constraints][:conIECSubmodel3g1conlytyndpendo] = @constraint(m, [istorcd=Istorcd,jh=[JH[1]],jd=[JD[1]],c=C], # Hour 1 of day 1 (to plot value)
            e_stor[istorcd,jh,jd,c] == EnergyInitstorcd[istorcd,c]
        )
    end
    m.ext[:constraints][:conIECSubmodel3g1cdonly] = @constraint(m, [istorcd=Istorcd,jh=[JH[1]],jd=[JD[1]],cdonly=CDonly], # Hour 1 of day 1 (to plot value)
        e_stor[istorcd,jh,jd,cdonly] == EnergyInitstorcd[istorcd,cdonly]
    )
    m.ext[:constraints][:conIECSubmodel3g2] = @constraint(m, [istorcd=Istorcd,jh=[JH[1]],jd=[JD[1]],cd=CD], # Hour 2 of day 1 
        e_stor[istorcd,jh+1,jd,cd] == e_stor[istorcd,jh,jd,cd] + inflow[cd,istorcd][jh + nTimesteps * (jd - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,jh,jd,cd] - dc_stor[istorcd,jh,jd,cd]/efficiency_storcd[istorcd]
    )
    m.ext[:constraints][:conIECSubmodel3g3] = @constraint(m, [istorcd=Istorcd,jhend=JH[2]:JH[end-1],jd=[JD[1]],cd=CD], # Hour 3 until hour 24 of day 1
        e_stor[istorcd,jhend+1,jd,cd] == e_stor[istorcd,jhend,jd,cd] + inflow[cd,istorcd][jhend + nTimesteps * (jd - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,jhend,jd,cd] - dc_stor[istorcd,jhend,jd,cd]/efficiency_storcd[istorcd]
    )    
    m.ext[:constraints][:conIECSubmodel3g4] = @constraint(m, [istorcd=Istorcd,jh=[JH[1]],jdbegin=JD[1]:JD[end-1],cd=CD], # Hour 1 of next day equals hour 24 of day itself
        e_stor[istorcd,jh,jdbegin+1,cd] == e_stor[istorcd,last(JH),jdbegin,cd] + inflow[cd,istorcd][last(JH) + nTimesteps * (jdbegin - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,last(JH),jdbegin,cd] - dc_stor[istorcd,last(JH),jdbegin,cd]/efficiency_storcd[istorcd]
    )
    m.ext[:constraints][:conIECSubmodel3g5] = @constraint(m, [istorcd=Istorcd,jhbegin=JH[1]:JH[end-1],jdmiddle=JD[2]:JD[end-1],cd=CD], # Hour 2 until hour 24 of day 2 until day 364
        e_stor[istorcd,jhbegin+1,jdmiddle,cd] == e_stor[istorcd,jhbegin,jdmiddle,cd] + inflow[cd,istorcd][jhbegin + nTimesteps * (jdmiddle - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,jhbegin,jdmiddle,cd] - dc_stor[istorcd,jhbegin,jdmiddle,cd]/efficiency_storcd[istorcd]
    )
    m.ext[:constraints][:conIECSubmodel3g6] = @constraint(m, [istorcd=Istorcd,jhbegin=JH[1]:JH[end-2],jd=[last(JD)],cd=CD], # Hour 2 until hour 23 of day 365
        e_stor[istorcd,jhbegin+1,jd,cd] == e_stor[istorcd,jhbegin,jd,cd] + inflow[cd,istorcd][jhbegin + nTimesteps * (jd - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,jhbegin,jd,cd] - dc_stor[istorcd,jhbegin,jd,cd]/efficiency_storcd[istorcd]
    )
    m.ext[:constraints][:conIECSubmodel3g7] = @constraint(m, [istorcd=Istorcd,jh=[JH[end-1]],jd=[last(JD)],cd=CD], # Hour 24 of day 365
        e_stor[istorcd,jh+1,jd,cd] == e_stor[istorcd,jh,jd,cd] + inflow[cd,istorcd][jh + nTimesteps * (jd - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,jh,jd,cd] - dc_stor[istorcd,jh,jd,cd]/efficiency_storcd[istorcd]
    )
    if tcs_zero_iec_sm3 == "yes"
        m.ext[:constraints][:conIECSubmodel3g8conlyzero] = @constraint(m, [istorcd=Istorcd,jh=[last(JH)],jd=[last(JD)],c=C], # Hour 24 of day 365 (to plot value)
            e_stor[istorcd,jh,jd,c] == 0
        )
    elseif tcs_zero_iec_sm3 == "no"
        m.ext[:constraints][:conIECSubmodel3g8conlytyndpendo] = @constraint(m, [istorcd=Istorcd,jh=[last(JH)],jd=[last(JD)],c=C], # Hour 24 of day 365 (to plot value)
            e_stor[istorcd,jh,jd,c] == EnergyFinalstorcd[istorcd,c]
        )
    end
    m.ext[:constraints][:conIECSubmodel3g8cdonly] = @constraint(m, [istorcd=Istorcd,jh=[last(JH)],jd=[last(JD)],cdonly=CDonly], # Hour 24 of day 365 (to plot value)
        e_stor[istorcd,jh,jd,cdonly] == EnergyFinalstorcd[istorcd,cdonly]
    )
    ## RES no charging
    m.ext[:constraints][:conIECSubmodel3d_NoChargeRES] = @constraint(m, [istorcdres=IstorcdRES,jh=JH,jd=JD,cd=CD],
        ch_stor[istorcdres,jh,jd,cd] <= 0
    )
    ## ROR no charging
    m.ext[:constraints][:conIECSubmodel3d_NoChargeROR] = @constraint(m, [istorcdror=IstorcdROR,jh=JH,jd=JD,cd=CD],
        ch_stor[istorcdror,jh,jd,cd] <= 0
    )
    ## ROR no SOC (only for countries with 'cap_E(ROR)=0')
    m.ext[:constraints][:conIECSubmodel3f_NoSOCROR] = @constraint(m, [istorcdror=IstorcdROR,jh=JH,jd=JD,cd=CD],
        e_stor[istorcdror,jh,jd,cd] <= 0
    )
    return m
end

## Model discription: focus country (baseload import or export demand) and neighboring countries (brownfield: based on TYNDP) - one year
function build_IEC_submodel_2!(m::Model) # Dispatch optimization in neighboring countries with specific import or export baseload demand in focus country
    #focus_country = "BE00"
    nTimesteps = 24
    nDays = 365
    ## ONLY ONE OF THE FOLLOWING FOUR OPTIONS CAN BE "yes" FOR STORAGE PROFILES
    storage_profiles_based_on_tcs_bm = "yes" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_tyndp/zero = "no"'
    storage_profiles_based_on_tcs_tyndp = "no" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_bm/zero = "no"' 
    storage_profiles_based_on_tcs_zero = "no" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_bm/tyndp = "no"'
    #storage_profiles_optimized_endogenously = "no" # Only "yes" if 'storage_profiles_based_on_tcs_bm/tyndp/zero = "no"'
    storage_profiles_fixed_partly = "yes" # "yes" if TCS-PARTLY FIXING, "no" if TCS-FIXING (or TCS-NO FIXING)
    which_case_partly_fixing = "Case 4" # "Case 1": two hourly; "Case 2": 1/(2PE), "Case 3": 1/PE; "Case 4": 2/PE

    ## Clear m.ext entries "variables", "expressions" and "constraints"
    m.ext[:variables] = Dict()
    m.ext[:expressions] = Dict()
    m.ext[:constraints] = Dict()

    ## Extract sets
    Icd = m.ext[:sets][:Icd]
    IDcd = m.ext[:sets][:IDcd]
    IVcd = m.ext[:sets][:IVcd]
    Iextra = m.ext[:sets][:Iextra]
    Istorcd = m.ext[:sets][:Istorcd]
    IstorcdRES = m.ext[:sets][:IstorcdRES]
    IstorcdROR = m.ext[:sets][:IstorcdROR]
    JH = m.ext[:sets][:JH]
    JD = m.ext[:sets][:JD]
    C = m.ext[:sets][:C]
    CD = m.ext[:sets][:CD]
    CDonly = m.ext[:sets][:CDonly]
    LinescdVector = m.ext[:sets][:LinescdVector]

    ## Extract time series data
    DEMANDcd = m.ext[:timeseries][:DEMANDcd] # Demand
    DEMANDc = m.ext[:parameters][:DEMANDc] # Baseload demand profile in focus country
    AFcd = m.ext[:timeseries][:AFcd] # Avaiability factors
    inflow = m.ext[:timeseries][:inflow]

    ## Extract parameters
    VOLL = m.ext[:parameters][:VOLL] # VOLL
    VCcd = m.ext[:parameters][:VCcd] # Variable costs
    CAPcdonly = m.ext[:parameters][:CAPcdonly] # Capacities in non-focus countries are fixed
    Fpos = m.ext[:parameters][:Fpos]
    Fneg = m.ext[:parameters][:Fneg]
    T = m.ext[:parameters][:T] # T = 1 if positive flow on line l implies inejction into country, -1 if flow exiting country and 0 is country not connected to line
    PHI = m.ext[:parameters][:PHI]
    CAPstor_energycd = m.ext[:parameters][:CAPstor_energycd] # Energy content of storage technologies of neighboring countries
    PEstorcd = m.ext[:parameters][:PEstorcd] # Power-energy ratio of storage technologies of neighboring countries
    efficiency_storcd = m.ext[:parameters][:efficiency_storcd] # Efficiency of storage technologies
    EnergyInitstorcd = m.ext[:parameters][:EnergyInitstorcd] # Initial state-of-charge of storage technologies of neighboring countries
    EnergyFinalstorcd = m.ext[:parameters][:EnergyFinalstorcd] # Final state-of-charge of storage technologies of neighboring countries
    if storage_profiles_based_on_tcs_bm == "yes" # Fix storage profiles based on Submodel 3 when using TCS-BM
        Estor_cdonly = m.ext[:parameters][:Estor_cdonly_tcs_bm]
    elseif storage_profiles_based_on_tcs_tyndp == "yes" # Fix storage profiles based on Submodel 3 when using TCS-TYNDP
        Estor_cdonly = m.ext[:parameters][:Estor_cdonly_tcs_tyndp]
    elseif storage_profiles_based_on_tcs_zero == "yes" # Fix storage profiles based on Submodel 3 when using TCS-ZERO
        Estor_cdonly = m.ext[:parameters][:Estor_cdonly_tcs_zero]
    end

    ## Create variables
    gen = m.ext[:variables][:gen] = @variable(m, [icd=Icd,jh=JH,jd=JD,cdonly=CDonly], lower_bound=0, base_name="generation") # [MW]
    ens =  m.ext[:variables][:ens] = @variable(m, [jh=JH,jd=JD,cdonly=CDonly], lower_bound=0, base_name="load_shedding") # [MW]
    ch_stor =  m.ext[:variables][:ch_stor] = @variable(m, [istorcd=Istorcd,jh=JH,jd=JD,cdonly=CDonly], lower_bound=0, base_name="charging_power") # [MW]
    dc_stor =  m.ext[:variables][:dc_stor] = @variable(m, [istorcd=Istorcd,jh=JH,jd=JD,cdonly=CDonly], lower_bound=0, base_name="discharging_power") # [MW]
    e_stor =  m.ext[:variables][:e_stor] = @variable(m, [istorcd=Istorcd,jh=JH,jd=JD,cdonly=CDonly], lower_bound=0, base_name="energy_content") # [MWh]
    flow = m.ext[:variables][:flow] = @variable(m, [l=LinescdVector,jh=JH,jd=JD], base_name="line_flow") # [MW]
    Tflow_abs = m.ext[:variables][:Tflow_abs] = @variable(m, [cd=CD,l=LinescdVector,jh=JH,jd=JD], lower_bound=0, base_name="T_times_line_flow_absolute_value") # [MW]
    k_pos =  m.ext[:variables][:k_pos] = @variable(m, [jh=JH,jd=JD,c=C], lower_bound=0, base_name="pos_deviation") # [MW]
    k_neg =  m.ext[:variables][:k_neg] = @variable(m, [jh=JH,jd=JD,c=C], lower_bound=0, base_name="neg_deviation") # [MW]

    ## Create affine expressions (= linear combinations of variables) - curt: [MW]
    curt = m.ext[:expressions][:curt] = @expression(m, [ivcd=IVcd,jh=JH,jd=JD,cdonly=CDonly],
        AFcd[ivcd,cdonly][jh,jd] * CAPcdonly[ivcd,cdonly] - gen[ivcd,jh,jd,cdonly]
    )

    ## Formulate objective 1a
    m.ext[:objective] = @objective(m, Min,
        + sum(VCcd[idcd] * gen[idcd,jh,jd,cdonly] for idcd in IDcd, jh in JH, jd in JD, cdonly in CDonly)
        + sum(ens[jh,jd,cdonly] * VOLL for jh in JH, jd in JD, cdonly in CDonly)
        + sum((k_pos[jh,jd,c] + k_neg[jh,jd,c]) * VOLL for jh in JH, jd in JD, c in C)
        + sum(PHI * Tflow_abs[cd,l,jh,jd] for l in LinescdVector, jh in JH, jd in JD, cd in CD)
    )

    ## Formulate constraints
    m.ext[:constraints][:conIECSubmodel2b] = @constraint(m, [jh=JH,jd=JD,cdonly=CDonly],
        sum(gen[icd,jh,jd,cdonly] for icd in Icd) + ens[jh,jd,cdonly] + sum(T[cdonly,l]*flow[l,jh,jd] for l in LinescdVector) + sum(dc_stor[istorcd,jh,jd,cdonly]-ch_stor[istorcd,jh,jd,cdonly] for istorcd in Istorcd) == DEMANDcd[cdonly][jh,jd]
    )
    m.ext[:constraints][:conIECSubmodel2c] = @constraint(m, [jh=JH,jd=JD,c=C],
        sum(T[c,l]*flow[l,jh,jd] for l in LinescdVector) - k_pos[jh,jd,c] + k_neg[jh,jd,c] == DEMANDc
    )
    m.ext[:constraints][:conIECSubmodel2d1] = @constraint(m, [ivcd=IVcd,jh=JH,jd=JD,cdonly=CDonly],
        gen[ivcd,jh,jd,cdonly] <= AFcd[ivcd,cdonly][jh,jd] * CAPcdonly[ivcd,cdonly]
    )
    m.ext[:constraints][:conIECSubmodel2d2] = @constraint(m, [idcd=IDcd,jh=JH,jd=JD,cdonly=CDonly],
        gen[idcd,jh,jd,cdonly] <= CAPcdonly[idcd,cdonly]
    )
    ## Flow constraints
    m.ext[:constraints][:conIECSubmodel2e1] = @constraint(m, [jh=JH,jd=JD,l=LinescdVector],
        Fneg[l] <= flow[l,jh,jd] <= Fpos[l]
    )
    m.ext[:constraints][:conIECSubmodel2e2] = @constraint(m, [cd=CD,l=LinescdVector,jh=JH,jd=JD],
        Tflow_abs[cd,l,jh,jd] >= T[cd,l]*flow[l,jh,jd]
    )
    m.ext[:constraints][:conIECSubmodel2e3] = @constraint(m, [cd=CD,l=LinescdVector,jh=JH,jd=JD],
        Tflow_abs[cd,l,jh,jd] >= -T[cd,l]*flow[l,jh,jd]
    )
    ## Load shedding
    m.ext[:constraints][:conIECSubmodel2f] = @constraint(m, [jh=JH,jd=JD,cdonly=CDonly],
        ens[jh,jd,cdonly] <= DEMANDcd[cdonly][jh,jd]
    )
    ## Storage constraints
    m.ext[:constraints][:conIECSubmodel2h] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,cdonly=CDonly],
        ch_stor[istorcd,jh,jd,cdonly] <= PEstorcd[istorcd,cdonly] * CAPstor_energycd[istorcd,cdonly]
    )
    m.ext[:constraints][:conIECSubmodel2i] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,cdonly=CDonly],
        dc_stor[istorcd,jh,jd,cdonly] <= PEstorcd[istorcd,cdonly] * CAPstor_energycd[istorcd,cdonly]
    )
    m.ext[:constraints][:conIECSubmodel2j] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,cdonly=CDonly],
        e_stor[istorcd,jh,jd,cdonly] <= CAPstor_energycd[istorcd,cdonly]
    )
    m.ext[:constraints][:conIECSubmodel2k1] = @constraint(m, [istorcd=Istorcd,jh=[JH[1]],jd=[JD[1]],cdonly=CDonly], # Hour 1 of day 1 (to plot value)
        e_stor[istorcd,jh,jd,cdonly] == EnergyInitstorcd[istorcd,cdonly]
    )
    m.ext[:constraints][:conIECSubmodel2k2] = @constraint(m, [istorcd=Istorcd,jh=[JH[1]],jd=[JD[1]],cdonly=CDonly], # Hour 2 of day 1 
        e_stor[istorcd,jh+1,jd,cdonly] == e_stor[istorcd,jh,jd,cdonly] + inflow[cdonly,istorcd][jh + nTimesteps * (jd - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,jh,jd,cdonly] - dc_stor[istorcd,jh,jd,cdonly]/efficiency_storcd[istorcd]
    )
    m.ext[:constraints][:conIECSubmodel2k3] = @constraint(m, [istorcd=Istorcd,jhend=JH[2]:JH[end-1],jd=[JD[1]],cdonly=CDonly], # Hour 3 until hour 24 of day 1
        e_stor[istorcd,jhend+1,jd,cdonly] == e_stor[istorcd,jhend,jd,cdonly] + inflow[cdonly,istorcd][jhend + nTimesteps * (jd - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,jhend,jd,cdonly] - dc_stor[istorcd,jhend,jd,cdonly]/efficiency_storcd[istorcd]
    )    
    m.ext[:constraints][:conIECSubmodel2k4] = @constraint(m, [istorcd=Istorcd,jh=[JH[1]],jdbegin=JD[1]:JD[end-1],cdonly=CDonly], # Hour 1 of next day equals hour 24 of day itself
        e_stor[istorcd,jh,jdbegin+1,cdonly] == e_stor[istorcd,last(JH),jdbegin,cdonly] + inflow[cdonly,istorcd][last(JH) + nTimesteps * (jdbegin - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,last(JH),jdbegin,cdonly] - dc_stor[istorcd,last(JH),jdbegin,cdonly]/efficiency_storcd[istorcd]
    )
    m.ext[:constraints][:conIECSubmodel2k5] = @constraint(m, [istorcd=Istorcd,jhbegin=JH[1]:JH[end-1],jdmiddle=JD[2]:JD[end-1],cdonly=CDonly], # Hour 2 until hour 24 of day 2 until day 364
        e_stor[istorcd,jhbegin+1,jdmiddle,cdonly] == e_stor[istorcd,jhbegin,jdmiddle,cdonly] + inflow[cdonly,istorcd][jhbegin + nTimesteps * (jdmiddle - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,jhbegin,jdmiddle,cdonly] - dc_stor[istorcd,jhbegin,jdmiddle,cdonly]/efficiency_storcd[istorcd]
    )
    m.ext[:constraints][:conIECSubmodel2k6] = @constraint(m, [istorcd=Istorcd,jhbegin=JH[1]:JH[end-2],jd=[last(JD)],cdonly=CDonly], # Hour 2 until hour 23 of day 365
        e_stor[istorcd,jhbegin+1,jd,cdonly] == e_stor[istorcd,jhbegin,jd,cdonly] + inflow[cdonly,istorcd][jhbegin + nTimesteps * (jd - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,jhbegin,jd,cdonly] - dc_stor[istorcd,jhbegin,jd,cdonly]/efficiency_storcd[istorcd]
    )
    m.ext[:constraints][:conIECSubmodel2k7] = @constraint(m, [istorcd=Istorcd,jh=[JH[end-1]],jd=[last(JD)],cdonly=CDonly], # Hour 24 of day 365
        e_stor[istorcd,jh+1,jd,cdonly] == e_stor[istorcd,jh,jd,cdonly] + inflow[cdonly,istorcd][jh + nTimesteps * (jd - 1)] + efficiency_storcd[istorcd]*ch_stor[istorcd,jh,jd,cdonly] - dc_stor[istorcd,jh,jd,cdonly]/efficiency_storcd[istorcd]
    )
    m.ext[:constraints][:conIECSubmodel2k8] = @constraint(m, [istorcd=Istorcd,jh=[last(JH)],jd=[last(JD)],cdonly=CDonly], # Hour 24 of day 365 (to plot value)
        e_stor[istorcd,jh,jd,cdonly] == EnergyFinalstorcd[istorcd,cdonly]
    )
    ## RES no charging
    m.ext[:constraints][:conIECSubmodel2h_NoChargeRES] = @constraint(m, [istorcdres=IstorcdRES,jh=JH,jd=JD,cdonly=CDonly],
        ch_stor[istorcdres,jh,jd,cdonly] <= 0
    )
    ## ROR no charging
    m.ext[:constraints][:conIECSubmodel2h_NoChargeROR] = @constraint(m, [istorcdror=IstorcdROR,jh=JH,jd=JD,cdonly=CDonly],
        ch_stor[istorcdror,jh,jd,cdonly] <= 0
    )
    ## ROR no SOC (only for countries with 'cap_E(ROR)=0')
    m.ext[:constraints][:conIECSubmodel2j_NoSOCROR] = @constraint(m, [istorcdror=IstorcdROR,jh=JH,jd=JD,cdonly=CDonly],
        e_stor[istorcdror,jh,jd,cdonly] <= 0
    )
    ## Storage variables are fixed based on IEC Submodel 3 using TCS-BM or TCS-TYNDP or TCS-ZERO
    if storage_profiles_based_on_tcs_bm == "yes" || storage_profiles_based_on_tcs_tyndp == "yes" || storage_profiles_based_on_tcs_zero == "yes"
        if storage_profiles_fixed_partly == "no"
            m.ext[:constraints][:conIECSubmodel2j_fixed_storage_profiles] = @constraint(m, [istorcd=Istorcd,jh=JH,jd=JD,cdonly=CDonly],
                e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
            )
        elseif storage_profiles_fixed_partly == "yes"
            if which_case_partly_fixing == "Case 1" # Fix every two hours
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles1] = @constraint(m, [istorcd=Istorcd,jhtwohourly=collect(1:2:nTimesteps),jd=JD,cdonly=CDonly],
                    e_stor[istorcd,jhtwohourly,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jhtwohourly + nTimesteps * (jd - 1)]
                )
            elseif which_case_partly_fixing == "Case 2" # Fix based on 1/(2PE)
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles2FR00a] = @constraint(m, [istorcd=["RES"],jh=[1],jd=collect(1:26:nDays),cdonly=["FR00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles2FR00b] = @constraint(m, [istorcd=["PS_C"],jh=collect(1:3:nTimesteps),jd=JD,cdonly=["FR00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles2FR00c] = @constraint(m, [istorcd=["PS_O"],jh=[1],jd=JD,cdonly=["FR00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles2DE00a] = @constraint(m, [istorcd=["RES"],jh=[1],jd=collect(1:4:nDays),cdonly=["DE00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles2DE00b] = @constraint(m, [istorcd=["PS_C"],jh=[1],jd=collect(1:2:nDays),cdonly=["DE00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles2DE00c] = @constraint(m, [istorcd=["PS_O"],jh=[1],jd=collect(1:6:nDays),cdonly=["DE00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles2UK00a] = @constraint(m, [istorcd=["PS_C"],jh=collect(1:4:nTimesteps),jd=JD,cdonly=["UK00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles2Battery] = @constraint(m, [istorcd=["Battery"],jh=collect(1:2:nTimesteps),jd=JD,cdonly=CDonly],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles2Hydrogen] = @constraint(m, [istorcd=["Hydrogen"],jh=[1],jd=collect(1:21:nDays),cdonly=CDonly],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
            elseif which_case_partly_fixing == "Case 3" # Fix based on 1/(PE)
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles3FR00a] = @constraint(m, [istorcd=["RES"],jh=[1],jd=collect(1:52:nDays),cdonly=["FR00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles3FR00b] = @constraint(m, [istorcd=["PS_C"],jh=collect(1:6:nTimesteps),jd=JD,cdonly=["FR00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles3FR00c] = @constraint(m, [istorcd=["PS_O"],jh=[1],jd=collect(1:2:nDays),cdonly=["FR00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles3DE00a] = @constraint(m, [istorcd=["RES"],jh=[1],jd=collect(1:8:nDays),cdonly=["DE00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles3DE00b] = @constraint(m, [istorcd=["PS_C"],jh=[1],jd=collect(1:4:nDays),cdonly=["DE00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles3DE00c] = @constraint(m, [istorcd=["PS_O"],jh=[1],jd=collect(1:12:nDays),cdonly=["DE00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles3UK00a] = @constraint(m, [istorcd=["PS_C"],jh=collect(1:8:nTimesteps),jd=JD,cdonly=["UK00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles3Battery] = @constraint(m, [istorcd=["Battery"],jh=collect(1:3:nTimesteps),jd=JD,cdonly=CDonly],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles3Hydrogen] = @constraint(m, [istorcd=["Hydrogen"],jh=[1],jd=collect(1:42:nDays),cdonly=CDonly],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
            elseif which_case_partly_fixing == "Case 4" # Fix based on 2/(PE)
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles4FR00a] = @constraint(m, [istorcd=["RES"],jh=[1],jd=collect(1:104:nDays),cdonly=["FR00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles4FR00b] = @constraint(m, [istorcd=["PS_C"],jh=collect(1:12:nTimesteps),jd=JD,cdonly=["FR00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles4FR00c] = @constraint(m, [istorcd=["PS_O"],jh=[1],jd=collect(1:4:nDays),cdonly=["FR00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles4DE00a] = @constraint(m, [istorcd=["RES"],jh=[1],jd=collect(1:16:nDays),cdonly=["DE00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles4DE00b] = @constraint(m, [istorcd=["PS_C"],jh=[1],jd=collect(1:8:nDays),cdonly=["DE00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles4DE00c] = @constraint(m, [istorcd=["PS_O"],jh=[1],jd=collect(1:24:nDays),cdonly=["DE00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles4UK00a] = @constraint(m, [istorcd=["PS_C"],jh=[1,19],jd=collect(1:3:nDays),cdonly=["UK00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles4UK00b] = @constraint(m, [istorcd=["PS_C"],jh=[13],jd=collect(2:3:nDays),cdonly=["UK00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles4UK00c] = @constraint(m, [istorcd=["PS_C"],jh=[7],jd=collect(3:3:nDays),cdonly=["UK00"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles4NOM1] = @constraint(m, [istorcd=["PS_O"],jh=[1],jd=collect(1:145:nDays),cdonly=["NOM1"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles4NON1] = @constraint(m, [istorcd=["PS_O"],jh=[1],jd=collect(1:320:nDays),cdonly=["NON1"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles4NOS0] = @constraint(m, [istorcd=["PS_O"],jh=[1],jd=collect(1:199:nDays),cdonly=["NOS0"]],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles4Battery] = @constraint(m, [istorcd=["Battery"],jh=collect(1:6:nTimesteps),jd=JD,cdonly=CDonly],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
                m.ext[:constraints][:conIECSubmodel2j_partly_fixed_storage_profiles4Hydrogen] = @constraint(m, [istorcd=["Hydrogen"],jh=[1],jd=collect(1:84:nDays),cdonly=CDonly],
                    e_stor[istorcd,jh,jd,cdonly] == Estor_cdonly[istorcd,cdonly][jh + nTimesteps * (jd - 1)]
                )
            end
        end
    end
    return m
end

## Model discription: focus country (greenfield) - one year - with or without storage in focus country - with cross-border trade
function build_IEC_submodel_1!(m::Model)
    storage_unit_investments_allowed = "yes" # "yes" or "no"
    nTimesteps = 24

    ## Clear m.ext entries "variables", "expressions" and "constraints"
    m.ext[:variables] = Dict()
    m.ext[:expressions] = Dict()
    m.ext[:constraints] = Dict()

    ## Extract sets
    I = m.ext[:sets][:I]
    ID = m.ext[:sets][:ID]
    IV = m.ext[:sets][:IV]
    Istor = m.ext[:sets][:Istor]
    #IstorPSO = m.ext[:sets][:IstorPSO]
    IstorRES = m.ext[:sets][:IstorRES]
    IstorROR = m.ext[:sets][:IstorROR]
    IstorNO = m.ext[:sets][:IstorNO]
    JH = m.ext[:sets][:JH]
    JD = m.ext[:sets][:JD]
    Pimp = m.ext[:sets][:Pimp]
    Pexp = m.ext[:sets][:Pexp]
    C = m.ext[:sets][:C]

    ## Extract time series data
    DEMAND = m.ext[:timeseries][:DEMAND] # Demand
    AF = m.ext[:timeseries][:AF] # Avaiability factors
    AFimp = m.ext[:timeseries][:AFimp] # Avaiability factors of import
    AFexp = m.ext[:timeseries][:AFexp] # Avaiability factors of export
    inflowc = m.ext[:timeseries][:inflowc] # Inflow of storage units

    ## Extract parameters
    VOLL = m.ext[:parameters][:VOLL] # VOLL
    VC = m.ext[:parameters][:VC] # Variable costs of generation units
    IC = m.ext[:parameters][:IC] # Investment costs of generation units
    ICstor = m.ext[:parameters][:ICstor] # Investment costs of storage units
    PEstorcd = m.ext[:parameters][:PEstorcd] # Power-energy ratio of storage technologies
    efficiency_stor = m.ext[:parameters][:efficiency_stor] # Efficiency of storage technologies
    VCimp = m.ext[:parameters][:VCimp] # Variable cost of import
    VCexp = m.ext[:parameters][:VCexp] # Variable cost of export

    ## Create variables
    cap_gen = m.ext[:variables][:cap_gen] = @variable(m, [i=I], lower_bound=0, base_name="capacity_generation") # [MW]
    cap_stor = m.ext[:variables][:cap_stor] = @variable(m, [istor=Istor], lower_bound=0, base_name="capacity_storage") # [MWh]
    gen = m.ext[:variables][:gen] = @variable(m, [i=I,jh=JH,jd=JD], lower_bound=0, base_name="generation") # [MW]
    ens =  m.ext[:variables][:ens] = @variable(m, [jh=JH,jd=JD], lower_bound=0, base_name="load_shedding") # [MW]
    ch_stor =  m.ext[:variables][:ch_stor] = @variable(m, [istor=Istor,jh=JH,jd=JD], lower_bound=0, base_name="charging_power") # [MW]
    dc_stor =  m.ext[:variables][:dc_stor] = @variable(m, [istor=Istor,jh=JH,jd=JD], lower_bound=0, base_name="discharging_power") # [MW]
    e_stor =  m.ext[:variables][:e_stor] = @variable(m, [istor=Istor,jh=JH,jd=JD], lower_bound=0, base_name="energy_content") # [MWh]
    imp =  m.ext[:variables][:imp] = @variable(m, [pimp=Pimp,jh=JH,jd=JD], lower_bound=0, base_name="import") # [MW]
    exp =  m.ext[:variables][:exp] = @variable(m, [pexp=Pexp,jh=JH,jd=JD], lower_bound=0, base_name="export") # [MW]

    ## Create affine expressions (= linear combinations of variables) - curt: [MW]
    curt = m.ext[:expressions][:curt] = @expression(m, [iv=IV,jh=JH,jd=JD],
        AF[iv][jh,jd] * cap_gen[iv] - gen[iv,jh,jd]
    )

    ## Formulate objective 1a
    m.ext[:objective] = @objective(m, Min,
        + sum(IC[i] * cap_gen[i] for i in I)
        + sum(ICstor[istor] * cap_stor[istor] for istor in Istor)
        + sum(VC[i] * gen[i,jh,jd] for i in ID, jh in JH, jd in JD)
        + sum(ens[jh,jd] * VOLL for jh in JH, jd in JD)
        + sum(imp[pimp,jh,jd] * VCimp[pimp] for pimp in Pimp, jh in JH, jd in JD)
        - sum(exp[pexp,jh,jd] * VCexp[pexp] for pexp in Pexp, jh in JH, jd in JD)
    )

    ## Formulate constraints
    m.ext[:constraints][:conIECSubmodel1b] = @constraint(m, [jh=JH,jd=JD],
        sum(gen[i,jh,jd] for i in I) + ens[jh,jd] + sum(dc_stor[istor,jh,jd]-ch_stor[istor,jh,jd] for istor in Istor) + sum(imp[pimp,jh,jd] for pimp in Pimp) - sum(exp[pexp,jh,jd] for pexp in Pexp) == DEMAND[jh,jd]
    )
    m.ext[:constraints][:conIECSubmodel1c1] = @constraint(m, [iv=IV,jh=JH,jd=JD],
        gen[iv,jh,jd] <= AF[iv][jh,jd] * cap_gen[iv]
    )
    m.ext[:constraints][:conIECSubmodel1c2] = @constraint(m, [id=ID,jh=JH,jd=JD],
        gen[id,jh,jd] <= cap_gen[id]
    )
    m.ext[:constraints][:conIECSubmodel1d] = @constraint(m, [istor=Istor,jh=JH,jd=JD,c=C],
        ch_stor[istor,jh,jd] <= PEstorcd[istor,c] * cap_stor[istor]
    )
    m.ext[:constraints][:conIECSubmodel1e] = @constraint(m, [istor=Istor,jh=JH,jd=JD,c=C],
        dc_stor[istor,jh,jd] <= PEstorcd[istor,c] * cap_stor[istor]
    )
    m.ext[:constraints][:conIECSubmodel1f] = @constraint(m, [istor=Istor,jh=JH,jd=JD],
        e_stor[istor,jh,jd] <= cap_stor[istor]
    )
    if storage_unit_investments_allowed == "yes"
        m.ext[:constraints][:conIECSubmodel1g1] = @constraint(m, [istor=Istor,jh=[JH[1]],jd=[JD[1]]], # Hour 1 of day 1 (to plot value)
            e_stor[istor,jh,jd] == 0 #cap_stor[istor]/2
        )
        m.ext[:constraints][:conIECSubmodel1g2] = @constraint(m, [istor=Istor,jh=[JH[1]],jd=[JD[1]]], # Hour 2 of day 1 
            e_stor[istor,jh+1,jd] == e_stor[istor,jh,jd] + inflowc[istor][jh + nTimesteps * (jd - 1)] + efficiency_stor[istor]*ch_stor[istor,jh,jd] - dc_stor[istor,jh,jd]/efficiency_stor[istor]
        )
        m.ext[:constraints][:conIECSubmodel1g3] = @constraint(m, [istor=Istor,jhend=JH[2]:JH[end-1],jd=[JD[1]]], # Hour 3 until hour 24 of day 1
            e_stor[istor,jhend+1,jd] == e_stor[istor,jhend,jd] + inflowc[istor][jhend + nTimesteps * (jd - 1)] + efficiency_stor[istor]*ch_stor[istor,jhend,jd] - dc_stor[istor,jhend,jd]/efficiency_stor[istor]
        )  
        m.ext[:constraints][:conIECSubmodel1g4] = @constraint(m, [istor=Istor,jh=[JH[1]],jdbegin=JD[1]:JD[end-1]], # Hour 1 of next day equals hour 24 of day itself
            e_stor[istor,jh,jdbegin+1] == e_stor[istor,last(JH),jdbegin] + inflowc[istor][last(JH) + nTimesteps * (jdbegin - 1)] + efficiency_stor[istor]*ch_stor[istor,last(JH),jdbegin] - dc_stor[istor,last(JH),jdbegin]/efficiency_stor[istor]
        )
        m.ext[:constraints][:conIECSubmodel1g5] = @constraint(m, [istor=Istor,jhbegin=JH[1]:JH[end-1],jdmiddle=JD[2]:JD[end-1]], # Hour 2 until hour 24 of day 2 until day 364
            e_stor[istor,jhbegin+1,jdmiddle] == e_stor[istor,jhbegin,jdmiddle] + inflowc[istor][jhbegin + nTimesteps * (jdmiddle - 1)] + efficiency_stor[istor]*ch_stor[istor,jhbegin,jdmiddle] - dc_stor[istor,jhbegin,jdmiddle]/efficiency_stor[istor]
        )
        m.ext[:constraints][:conIECSubmodel1g6] = @constraint(m, [istor=Istor,jhbegin=JH[1]:JH[end-2],jd=[last(JD)]], # Hour 2 until hour 23 of day 365
            e_stor[istor,jhbegin+1,jd] == e_stor[istor,jhbegin,jd] + inflowc[istor][jhbegin + nTimesteps * (jd - 1)] + efficiency_stor[istor]*ch_stor[istor,jhbegin,jd] - dc_stor[istor,jhbegin,jd]/efficiency_stor[istor]
        )
        m.ext[:constraints][:conIECSubmodel1g7] = @constraint(m, [istor=Istor,jh=[JH[end-1]],jd=[last(JD)]], # Hour 24 of day 365
            e_stor[istor,jh+1,jd] == e_stor[istor,jh,jd] + inflowc[istor][jh + nTimesteps * (jd - 1)] + efficiency_stor[istor]*ch_stor[istor,jh,jd] - dc_stor[istor,jh,jd]/efficiency_stor[istor]
        )
        m.ext[:constraints][:conIECSubmodel1g8] = @constraint(m, [istor=Istor,jh=[last(JH)],jd=[last(JD)]], # Hour 24 of day 365 (to plot value)
            e_stor[istor,jh,jd] == 0 #cap_stor[istor]/2
        )
        ## RES no charging
        m.ext[:constraints][:conIECSubmodel1d_NoChargeRES] = @constraint(m, [istorres=IstorRES,jh=JH,jd=JD],
            ch_stor[istorres,jh,jd] <= 0
        )
        ## ROR no charging
        m.ext[:constraints][:conIECSubmodel1d_NoChargeROR] = @constraint(m, [istorror=IstorROR,jh=JH,jd=JD],
            ch_stor[istorror,jh,jd] <= 0
        )
        ## ROR no SOC (only if 'cap_E(ROR)=0')
        m.ext[:constraints][:conIECSubmodel1f_NoSOCROR] = @constraint(m, [istorror=IstorROR,jh=JH,jd=JD],
            e_stor[istorror,jh,jd] <= 0
        )
        ## Assume Belgium is not allowed to invest in PS_C, PS_O, RES and ROR (only investments in battery and hydrogen possible)
        #m.ext[:constraints][:conIECSubmodel1NoPSO] = @constraint(m, [istorpso=IstorPSO],
        #    cap_stor[istorpso] <= 0
        #)
        #m.ext[:constraints][:conIECSubmodel1NoRES] = @constraint(m, [istorres=IstorRES],
        #    cap_stor[istorres] <= 0
        #)
        m.ext[:constraints][:conIECSubmodel1NOTallSTOR] = @constraint(m, [istorno=IstorNO],
            cap_stor[istorno] <= 0
        )
    elseif storage_unit_investments_allowed == "no" # Removing storage (no constraints '1g')
        m.ext[:constraints][:conIECSubmodel1NoStorageUnitsAllowed] = @constraint(m, [istor=Istor],
            cap_stor[istor] <= 0
        )
    end
    m.ext[:constraints][:conIECSubmodel1h] = @constraint(m, [pimp=Pimp,jh=JH,jd=JD],
        imp[pimp,jh,jd] <= AFimp[pimp][jh,jd]
    )
    m.ext[:constraints][:conIECSubmodel1i] = @constraint(m, [pexp=Pexp,jh=JH,jd=JD],
        exp[pexp,jh,jd] <= AFexp[pexp][jh,jd]
    )
    m.ext[:constraints][:conIECSubmodel1j] = @constraint(m, [jh=JH,jd=JD],
        ens[jh,jd] <= DEMAND[jh,jd]
    )
    return m
end

## Model discription: focus country (real trade demand) and neighboring countries (brownfield: based on TYNDP) - one year
function build_IEC_submodel_4!(m::Model) # Dispatch optimization in neighboring countries with real trade demand in focus country
    ## Recall implementation from IEC Submodel 2
    m = build_IEC_submodel_2!(m::Model)
    
    ## Recall required sets
    JH = m.ext[:sets][:JH]
    JD = m.ext[:sets][:JD]
    C = m.ext[:sets][:C]
    LinescdVector = m.ext[:sets][:LinescdVector]

    ## Extract real demand time series from Submodel 1
    Dc_trade_real = m.ext[:timeseries][:Dc_trade_real] # Real trade demand profile in focus country

    ## Recall required parameter
    T = m.ext[:parameters][:T]

    ## Recall required variables
    flow = m.ext[:variables][:flow]
    k_pos =  m.ext[:variables][:k_pos]
    k_neg =  m.ext[:variables][:k_neg]

    ## Remove constraint with baseload demand in focus country
    for jh in JH, jd in JD, c in C
        delete(m,m.ext[:constraints][:conIECSubmodel2c][jh,jd,c])
    end

    ## Define new constraint with real demand in focus country
    m.ext[:constraints][:conIECSubmodel2c] = @constraint(m, [jh=JH,jd=JD,c=C],
        sum(T[c,l]*flow[l,jh,jd] for l in LinescdVector) - k_pos[jh,jd,c] + k_neg[jh,jd,c] == Dc_trade_real[jh,jd]
    )
    return m
end

## Build model (choose model and corresponding model parameters by removing corresponding code lines)
## SINGLE COUNTRY MODEL
#build_step_3_single_country_model!(m)
#plot_figures = 1
#storage_included_single_country = "no" # "yes" or "no"
#tyndp_iec_sm3 = "no" # "no" by default
#tcs_zero_iec_sm3 = "no" # "no" by default

## ENDOGENOUS MODEL
build_endogenous_direct_countries_model!(m)
plot_figures = 2
storage_included = "yes" # "yes" or "no"
all_direct_neighboring_countries = "yes" # "yes" by default (test with one direct neighboring country with "no")
tyndp_iec_sm3 = "no" # "no" by default
tcs_zero_iec_sm3 = "no" # "no" by default

## IEC SUBMODEL 3
#build_IEC_submodel_3!(m)
#plot_figures = 3
#tyndp_iec_sm3 = "no" #"no" or "yes" -> ONLY YES IF "tcs_zero_iec_sm3 = "no""! -> then TCS-TYNDP
#tcs_zero_iec_sm3 = "no" #"no" or "yes" -> ONLY YES IF "tyndp_iec_sm3 = "no""! -> then TCS-ZERO, otherwise TCS-BM
#all_direct_neighboring_countries = "yes" # "yes" by default (test with one direct neighboring country with "no")

## IEC SUBMODEL 2
#build_IEC_submodel_2!(m)
#plot_figures = 4
#all_direct_neighboring_countries = "yes" # "yes" by default (test with one direct neighboring country with "no")
#all_possible_trade_levels = "yes" # "yes" by default (test with reduced amount of trade levels with "no")
### ONLY ONE OF THE FOLLOWING FOUR OPTIONS CAN BE "yes" FOR STORAGE PROFILES
#storage_profiles_based_on_tcs_bm = "yes" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_tyndp/zero = "no"' 
#storage_profiles_based_on_tcs_tyndp = "no" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_bm/zero = "no"'
#storage_profiles_based_on_tcs_zero = "no" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_bm/tyndp = "no"'
#storage_profiles_optimized_endogenously = "no" # Only "yes" if 'storage_profiles_based_on_tcs_bm/tyndp/zero = "no"'
#reduced_lambdas = "yes" # "no" if TCS-NO FIXING accurately, "yes" if TCS-NO FIXING roughly
#storage_profiles_fixed_partly = "yes" # "yes" if TCS-PARTLY FIXING, "no" if TCS-FIXING (or TCS-NO FIXING)
#which_case_partly_fixing = "Case 4" # "Case 1": two hourly; "Case 2": 1/(2PE), "Case 3": 1/PE; "Case 4": 2/PE
#tyndp_iec_sm3 = "no" # "no" by default
#tcs_zero_iec_sm3 = "no" # "no" by default
#lambda_needed = "no" # Only "yes" if building IEC SUBMODEL 1

## IEC SUBMODEL 1
#build_IEC_submodel_1!(m)
#plot_figures = 5
#storage_unit_investments_allowed = "yes" # "yes" or "no"
### ONLY ONE OF THE FOLLOWING FOUR OPTIONS CAN BE "yes" FOR MODEL OUTPUT
#storage_profiles_based_on_tcs_bm = "yes" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_tyndp/zero = "no"'
#storage_profiles_based_on_tcs_tyndp = "no" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_bm/zero = "no"' 
#storage_profiles_based_on_tcs_zero = "no" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_bm/tyndp = "no"'
#storage_profiles_optimized_endogenously = "no" # Only "yes" if 'storage_profiles_based_on_tcs_bm/tyndp/zero = "no"'
#tyndp_iec_sm3 = "no" # "no" by default
#tcs_zero_iec_sm3 = "no" # "no" by default
#lambda_needed = "yes" # "yes" by default

## IEC SUBMODEL 4
#build_IEC_submodel_4!(m)
#plot_figures = 6
#all_direct_neighboring_countries = "yes" # "yes" by default (test with one direct neighboring country with "no")
#storage_unit_investments_allowed = "yes" # "yes" or "no"
### ONLY ONE OF THE FOLLOWING FOUR OPTIONS CAN BE "yes" FOR STORAGE PROFILES
#storage_profiles_based_on_tcs_bm = "yes" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_tyndp/zero = "no"' 
#storage_profiles_based_on_tcs_tyndp = "no" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_bm/zero = "no"'
#storage_profiles_based_on_tcs_zero = "no" # Only "yes" if 'storage_profiles_optimized_endogenously/based_on_tcs_bm/tyndp = "no"'
#storage_profiles_optimized_endogenously = "no" # Only "yes" if 'storage_profiles_based_on_tcs_bm/tyndp/zero = "no"'
#tyndp_iec_sm3 = "no" # "no" by default
#tcs_zero_iec_sm3 = "no" # "no" by default
#lambda_needed = "no" # Only "yes" if building IEC SUBMODEL 1

## Step 4: solve
optimize!(m)

## Check termination status
print(
"""

Termination status: $(termination_status(m))

"""
)

## Print some output
#@show value.(m.ext[:objective])
if plot_figures == 1
    #@show value(m.ext[:objective])/sum(m.ext[:timeseries][:DEMAND]) # Average generation cost for single country - [EUR/MW] = [EUR/MWh] since delta t = 1h
    @show value.(m.ext[:variables][:cap_gen])
elseif plot_figures == 2
    #@show value(m.ext[:objective])/(sum(sum(m.ext[:timeseries][:DEMANDcd][cd]) for cd in m.ext[:sets][:CD])) # Average generation cost for system with single country and direct neighboring countries - [EUR/MW] = [EUR/MWh] since delta t = 1h
    @show value.(m.ext[:variables][:cap_gen])
end
#@show value.(sum(m.ext[:variables][:gen][i,jh,jd] for jh in m.ext[:sets][:JH], jd in m.ext[:sets][:JD])/1000000 for i in m.ext[:sets][:I])
#@show value.(sum(m.ext[:variables][:gen][iv,jh,jd] + m.ext[:expressions][:curt][iv,jh,jd] for jh in m.ext[:sets][:JH], jd in m.ext[:sets][:JD])/1000000 for iv in m.ext[:sets][:IV])
#@show value.(m.ext[:variables][:gen])
#@show value.(m.ext[:variables][:flow])

## Warning signal: tcs_zero cannot be "yes" if tyndp is "yes"
if plot_figures == 3
    if tyndp_iec_sm3 == "yes"
        if tcs_zero_iec_sm3 == "yes"
            print(
                """

                tcs_zero cannot be "yes" if tyndp is "yes": ERROR

                """
            )
        end
    end
end

## Step 5: interpretation
using Plots
using StatsPlots

## Sets
JH = m.ext[:sets][:JH]
JD = m.ext[:sets][:JD]
I = m.ext[:sets][:I]
IV = m.ext[:sets][:IV]
ID = m.ext[:sets][:ID]
IVcd = m.ext[:sets][:IVcd]
Istor = m.ext[:sets][:Istor]
Istorcd = m.ext[:sets][:Istorcd]
Icd = m.ext[:sets][:Icd]
C = m.ext[:sets][:C]
CD = m.ext[:sets][:CD]
CDonly = m.ext[:sets][:CDonly]
LinescdVector = m.ext[:sets][:LinescdVector]
Pimp = m.ext[:sets][:Pimp]
Pexp = m.ext[:sets][:Pexp]

## Time series data
DEMAND = m.ext[:timeseries][:DEMAND]
DEMANDcd = m.ext[:timeseries][:DEMANDcd]

## Parameters
VOLL = m.ext[:parameters][:VOLL]
VC = m.ext[:parameters][:VC]
VCcd = m.ext[:parameters][:VCcd]
IC = m.ext[:parameters][:IC]
ICcd = m.ext[:parameters][:ICcd]
ICstor = m.ext[:parameters][:ICstor]
Fpos = m.ext[:parameters][:Fpos]
Fneg = m.ext[:parameters][:Fneg]
Fpos_sum_fc = m.ext[:parameters][:Fpos_sum_fc]
Fneg_sum_fc = m.ext[:parameters][:Fneg_sum_fc]
T = m.ext[:parameters][:T]

## Variables/expressions
gen = value.(m.ext[:variables][:gen])
ens = value.(m.ext[:variables][:ens])
curt = value.(m.ext[:expressions][:curt])

## Create dictionary for outputs
m.ext[:ouputs] = Dict()

## Time parameters
nTimesteps = 24
TIMES = []
for jd in JD, jh in JH
    push!(TIMES, jh + nTimesteps * (jd - 1))
end

## Create .CSV files of (intermediate) results
if plot_figures == 1
    ## Call variables
    cap_gen = value.(m.ext[:variables][:cap_gen])
    λ = dual.(m.ext[:constraints][:conSingleCountry1b]) # [EUR/MWh]
    ## Calculate production for considered year
    total_production = m.ext[:ouputs][:total_production] = Dict() # [MWh]
    for i in I
        if i ∈ IV
            total_production[i] = value.(sum(gen[i,jh,jd] + curt[i,jh,jd] for jh in JH, jd in JD))
        else
            total_production[i] = value.(sum(gen[i,jh,jd] for jh in JH, jd in JD))
        end
    end
    ## Calculate total cost for considered year
    total_cost = m.ext[:ouputs][:total_cost] = Dict() # [EUR]
    total_cost["CAPEX"] = sum(ICcd[i] * cap_gen[i] for i in I) # CAPEX
    total_cost["OPEX"] = sum(VCcd[id] * gen[id,jh,jd] for id in ID, jh in JH, jd in JD) # OPEX due to dispatchable generators
    + sum(VOLL * ens[jh,jd] for jh in JH, jd in JD) # OPEX due to not meeting demand
    COMP = ["CAPEX", "OPEX"]
    ## Create arrays for plotting
    genvec = [gen[i,jh,jd] for i in I, jh in JH, jd in JD]
    cap_genvec = [cap_gen[i] for i in I]
    curtvec = [curt[iv,jh,jd] for iv in IV, jh in JH, jd in JD]
    λvec = [λ[jh,jd] for jh in JH, jd in JD]
    productionvec = [total_production[i] for i in I]
    costvec = [total_cost[comp] for comp in COMP]
    if storage_included_single_country == "no"
        ## Save results of focus country from single country model without storage in csv.file
        ## Save total production and installed capacities in focus country
        production_fc_from_single_country_model = []
        for i in I
            push!(production_fc_from_single_country_model,total_production[i])
        end
        capacity_fc_from_single_country_model = []
        for capacity in value.(cap_gen[:])
            push!(capacity_fc_from_single_country_model,capacity)
        end
        #CSV.write(joinpath(@__DIR__,"OutputData","Single country model no storage","Cap_Prod_FC_single_country.csv"),  DataFrame("Technology" => I, "Capacity" => capacity_fc_from_single_country_model, "Production" => production_fc_from_single_country_model))
        ## Save cost components in focus country
        cost_fc_from_single_country_model = []
        for comp in COMP
            push!(cost_fc_from_single_country_model,total_cost[comp])
        end
        #CSV.write(joinpath(@__DIR__,"OutputData","Single country model no storage","Cost_Comp_FC_single_country.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_single_country_model))
        #CSV.write(joinpath(@__DIR__,"OutputData","Single country model no storage","CompCost_FC_single_country.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
    #elseif storage_included_single_country == "yes"
    end
elseif plot_figures == 2
    ## Select technologies and countries for which you would like to plot: 
    #i = [4,7,9,10,11] #five main technologies for plots of generation and capacity mix of focus country
    #fc = 1 # Focus country
    fc_name = "BE00"
    #cd = 2 # Direct neighboring country
    if all_direct_neighboring_countries == "no"
        cd_name = "FR00" # Or "FR00" or "NL00" or "UK00" or "DE00" if only one country
    elseif all_direct_neighboring_countries == "yes"
        cd_name = "FRNLUKDE"
    end
    #line = 1
    ## Call variables
    cap_gen = value.(m.ext[:variables][:cap_gen])
    cap_stor = value.(m.ext[:variables][:cap_stor])
    λ = dual.(m.ext[:constraints][:conEndogenous1b]) # [EUR/MWh]
    flow = value.(m.ext[:variables][:flow])
    ## Calculate production for considered year
    total_production = m.ext[:ouputs][:total_production] = Dict() # [MWh]
    for icd in Icd, c in C
        if icd ∈ IVcd
            total_production[icd,c] = value.(sum(gen[icd,jh,jd,c] + curt[icd,jh,jd,c] for jh in JH, jd in JD))
        else
            total_production[icd,c] = value.(sum(gen[icd,jh,jd,c] for jh in JH, jd in JD))
        end
    end
    ## Calculate total import of focus country for considered year
    total_import = m.ext[:ouputs][:total_import] = Dict() # [MWh]
    total_export = m.ext[:ouputs][:total_export] = Dict() # [MWh]
    for c in C
        total_import[c] = sum(max(T[c,l]*flow[l,jh,jd],0) for l in LinescdVector, jh in JH, jd in JD)
        total_export[c] = sum(max(-T[c,l]*flow[l,jh,jd],0) for l in LinescdVector, jh in JH, jd in JD)
    end
    ## Calculate total cost for considered year
    total_cost = m.ext[:ouputs][:total_cost] = Dict() # [EUR]
    for c in C
        total_cost[c,"CAPEX"] = sum(ICcd[i] * cap_gen[i,c] for i in I) # CAPEX of generation units
        + sum(ICstor[istorcd] * cap_stor[istorcd,c] for istorcd in Istorcd) # CAPEX of storage units
        total_cost[c,"OPEX"] = sum(VCcd[id] * gen[id,jh,jd,c] for id in ID, jh in JH, jd in JD) # OPEX due to dispatchable generators
        + sum(VOLL * ens[jh,jd,c] for jh in JH, jd in JD) # OPEX due to not meeting demand
        total_cost[c,"Import"] = sum(λ[jh,jd,c] * max(T[c,l]*flow[l,jh,jd],0) for l in LinescdVector, jh in JH, jd in JD) # Import cost
        total_cost[c,"Export"] = -sum(λ[jh,jd,c] * max(-T[c,l]*flow[l,jh,jd],0) for l in LinescdVector, jh in JH, jd in JD) # Export Revenue
        total_cost[c,"Congestion"] = -sum(abs((λ[jh,jd,c] - λ[jh,jd,cdonly])/2 * T[c,l] * T[cdonly,l] * flow[l,jh,jd]) for l in LinescdVector, jh in JH, jd in JD, cdonly in CDonly) # Congestion rents
    end
    COMP = ["CAPEX", "OPEX", "Import", "Export", "Congestion"]
    ## Create arrays for plotting
    genvec = [gen[icd,jh,jd,cd] for icd in Icd, jh in JH, jd in JD, cd in CD]
    cap_genvec = [cap_gen[icd,cd] for icd in Icd, cd in CD]
    #ensvec = [ens[jh,jd,cd] for jh in JH, jd in JD, cd in CD]
    curtvec = [curt[ivcd,jh,jd,cd] for ivcd in IVcd, jh in JH, jd in JD, cd in CD]
    λvec = [λ[jh,jd,cd] for jh in JH, jd in JD, cd in CD]
    flowvec = [flow[l,jh,jd] for l in LinescdVector, jh in JH, jd in JD]
    productionvec = [total_production[icd,c] for icd in Icd, c in C]
    impvec = [total_import[c] for c in C]
    expvec = [total_export[c] for c in C]
    costvec = [total_cost[c,comp] for c in C, comp in COMP]
    if storage_included == "no"
        if cd_name == "FRNLUKDE"
            ## Save results of focus country from endogenous model without storage in csv.file
            ## Save total production and installed capacities in focus country
            production_fc_from_endo_no_stor_model = []
            for icd in Icd
                push!(production_fc_from_endo_no_stor_model,total_production[icd,fc_name])
            end
            capacity_fc_from_endo_no_stor_model = []
            for capacity in value.(cap_gen[:,fc_name])
                push!(capacity_fc_from_endo_no_stor_model,capacity)
            end
            #CSV.write(joinpath(@__DIR__,"OutputData","Endogenous model direct neighbors no storage","Cap_Prod_FC_endo_no_stor.csv"),  DataFrame("Technology" => Icd, "Capacity" => capacity_fc_from_endo_no_stor_model, "Production" => production_fc_from_endo_no_stor_model))
            ## Save total import and export in focus country
            #CSV.write(joinpath(@__DIR__,"OutputData","Endogenous model direct neighbors no storage","Imp_Exp_FC_endo_no_stor.csv"),  DataFrame("Import" => total_import[fc_name], "Export" => total_export[fc_name]))
            ## Save cost components in focus country
            cost_fc_from_endo_no_stor_model = []
            for comp in COMP
                push!(cost_fc_from_endo_no_stor_model,total_cost[fc_name,comp])
            end
            #CSV.write(joinpath(@__DIR__,"OutputData","Endogenous model direct neighbors no storage","Cost_Comp_FC_endo_no_stor.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_endo_no_stor_model))
        end
    elseif storage_included == "yes"
        if cd_name == "FRNLUKDE"
            ## Save total production and installed capacities, total import and export, and cost components in focus country from endogenous model with storage in csv.file
            production_fc_from_endo_model = []
            for icd in Icd
                push!(production_fc_from_endo_model,total_production[icd,fc_name])
            end
            capacity_fc_from_endo_model = []
            for capacity in value.(cap_gen[:,fc_name])
                push!(capacity_fc_from_endo_model,capacity)
            end
            capacity_storage_fc_from_endo_model = []
            for capacity_storage in value.(cap_stor[:,fc_name])
                push!(capacity_storage_fc_from_endo_model,capacity_storage)
            end
            cost_fc_from_endo_model = []
            for comp in COMP
                push!(cost_fc_from_endo_model,total_cost[fc_name,comp])
            end
            CSV.write(joinpath(@__DIR__,"OutputData","Endogenous model","Cap_Prod_FC_endo_stor.csv"),  DataFrame("Technology" => Icd, "Capacity" => capacity_fc_from_endo_model, "Production" => production_fc_from_endo_model))
            CSV.write(joinpath(@__DIR__,"OutputData","Endogenous model","CapStor_FC_endo_stor.csv"),  DataFrame("Storage unit" => Istorcd, "Capacity" => capacity_storage_fc_from_endo_model))
            CSV.write(joinpath(@__DIR__,"OutputData","Endogenous model","Imp_Exp_FC_endo_stor.csv"),  DataFrame("Import" => total_import[fc_name], "Export" => total_export[fc_name]))
            CSV.write(joinpath(@__DIR__,"OutputData","Endogenous model","Cost_Comp_FC_endo_stor.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_endo_model))
            CSV.write(joinpath(@__DIR__,"OutputData","Endogenous model","CompCost_endo_stor.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        end
    end
elseif plot_figures == 3
    ## Call variables
    e_stor = value.(m.ext[:variables][:e_stor])
    #ch_stor = value.(m.ext[:variables][:ch_stor])
    #dc_stor = value.(m.ext[:variables][:dc_stor])
    ## Save discharge variables of neigboring countries
    for istorcd in Istorcd
        df_e_stor = DataFrame("Timestep" => TIMES)
        #df_ch_stor = DataFrame("Timestep" => TIMES)
        #df_dc_stor = DataFrame("Timestep" => TIMES)
        i_countA = 2
        for cdonly in CDonly
            soc_istorcd_cdonly_from_iec_model_3 = []
            #charge_istorcd_cdonly_from_iec_model_3 = []
            #discharge_istorcd_cdonly_from_iec_model_3 = []
            for jd in JD, jh in JH
                push!(soc_istorcd_cdonly_from_iec_model_3, value.(e_stor[istorcd,jh,jd,cdonly]))
                #push!(charge_istorcd_cdonly_from_iec_model_3, value.(ch_stor[istorcd,jh,jd,cdonly]))
                #push!(discharge_istorcd_cdonly_from_iec_model_3, value.(dc_stor[istorcd,jh,jd,cdonly]))
            end
            insertcols!(df_e_stor, i_countA, cdonly => soc_istorcd_cdonly_from_iec_model_3)
            #insertcols!(df_ch_stor, i, cdonly => charge_istorcd_cdonly_from_iec_model_3)
            #insertcols!(df_dc_stor, i, cdonly => discharge_istorcd_cdonly_from_iec_model_3)
            i_countA = i_countA + 1
        end
        if all_direct_neighboring_countries == "yes"
            if tyndp_iec_sm3 == "no"
                if tcs_zero_iec_sm3 == "no"
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS BM","SOC_"*string(istorcd)*"_DNC_iec_sm_3_tcs_bm.csv"), df_e_stor)
                    #CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS BM","Ch_"*string(istorcd)*"_DNC_iec_sm_3_tcs_bm.csv"), df_ch_stor)
                    #CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS BM","Dc_"*string(istorcd)*"_DNC_iec_sm_3_tcs_bm.csv"), df_dc_stor)
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS BM","CompCost_iec_sm_3_tcs_bm.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
                elseif tcs_zero_iec_sm3 == "yes"
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS ZERO","SOC_"*string(istorcd)*"_DNC_iec_sm_3_tcs_zero.csv"), df_e_stor)
                    #CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS ZERO","Ch_"*string(istorcd)*"_DNC_iec_sm_3_tcs_zero.csv"), df_ch_stor)
                    #CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS ZERO","Dc_"*string(istorcd)*"_DNC_iec_sm_3_tcs_zero.csv"), df_dc_stor)
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS ZERO","CompCost_iec_sm_3_tcs_zero.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
                end
            elseif tyndp_iec_sm3 == "yes"
                if tcs_zero_iec_sm3 == "no"
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS TYNDP","SOC_"*string(istorcd)*"_DNC_iec_sm_3_tcs_tyndp.csv"), df_e_stor)
                    #CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS TYNDP","Ch_"*string(istorcd)*"_DNC_iec_sm_3_tcs_tyndp.csv"), df_ch_stor)
                    #CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS TYNDP","Dc_"*string(istorcd)*"_DNC_iec_sm_3_tcs_tyndp.csv"), df_dc_stor)
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 3","TCS TYNDP","CompCost_iec_sm_3_tcs_tyndp.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
                end
            end
        elseif all_direct_neighboring_countries == "no"
            #CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 3","TEST FR","SOC_"*string(istorcd)*"_DNC_iec_sm_3_test.csv"), df_e_stor)
            #CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 3","TEST FR","Ch_"*string(istorcd)*"_DNC_iec_sm_3_test.csv"), df_ch_stor)
            #CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 3","TEST FR","Dc_"*string(istorcd)*"_DNC_iec_sm_3_test.csv"), df_dc_stor)
        end
    end
elseif plot_figures == 4
    ## Call variables
    λ_fc = dual.(m.ext[:constraints][:conIECSubmodel2c]) # [EUR/MWh]
    ## Save dual variable, i.e. electricity price for focus country when one extra MW of demand
    df_λ = DataFrame("Timestep" => TIMES)
    λ_fc_from_iec_submodel_2 = []
    if storage_profiles_based_on_tcs_bm == "yes" || storage_profiles_based_on_tcs_tyndp == "yes" || storage_profiles_based_on_tcs_zero == "yes"
        if storage_profiles_fixed_partly == "no"
            for c in C, jd in JD, jh in JH
                push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 4))
            end
        elseif storage_profiles_fixed_partly == "yes"
            for c in C, jd in JD, jh in JH
                if value.(λ_fc[jh,jd,c]) < 1 && value.(λ_fc[jh,jd,c]) > -1
                    push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 2))
                elseif value.(λ_fc[jh,jd,c]) < 98 && value.(λ_fc[jh,jd,c]) > 94
                    push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 4))
                elseif value.(λ_fc[jh,jd,c]) < 134 && value.(λ_fc[jh,jd,c]) > 130
                    push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 5))
                elseif value.(λ_fc[jh,jd,c]) < -7999 && value.(λ_fc[jh,jd,c]) > -8001
                    push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 1))
                elseif value.(λ_fc[jh,jd,c]) < 8001 && value.(λ_fc[jh,jd,c]) > 7999
                    push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 1))
                else
                    push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); base = 2, digits = 1))
                end
            end
        end
    elseif storage_profiles_optimized_endogenously == "yes"
        if reduced_lambdas == "no"
            for c in C, jd in JD, jh in JH
                push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 4))
            end
        elseif reduced_lambdas == "yes"
            for c in C, jd in JD, jh in JH
                if value.(λ_fc[jh,jd,c]) < 1 && value.(λ_fc[jh,jd,c]) > -1
                    push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 2))
                elseif value.(λ_fc[jh,jd,c]) < 98 && value.(λ_fc[jh,jd,c]) > 94
                    push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 4))
                elseif value.(λ_fc[jh,jd,c]) < 134 && value.(λ_fc[jh,jd,c]) > 130
                    push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 5))
                elseif value.(λ_fc[jh,jd,c]) < -7999 && value.(λ_fc[jh,jd,c]) > -8001
                    push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 1))
                elseif value.(λ_fc[jh,jd,c]) < 8001 && value.(λ_fc[jh,jd,c]) > 7999
                    push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 1))
                else
                    push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); base = 2, digits = 1))
                end
            end
        end
    end
    insertcols!(df_λ, 2, string(m.ext[:parameters][:DEMANDc]) => λ_fc_from_iec_submodel_2)
    i_countB = 3
    ## Count solve time of model
    solve_time_count = solve_time(m)
    variables_count = num_variables(m)
    constraints_count = num_constraints(m; count_variable_in_set_constraints = true)
    nonzeros_count = MOI.get(m, Gurobi.ModelAttribute("NumNZs"))
    for baseload_level in m.ext[:parameters][:baseload_levels]
        ## Update constraints
        for jh=JH, jd=JD, c=C
            set_normalized_rhs(m.ext[:constraints][:conIECSubmodel2c][jh,jd,c], baseload_level)
        end
        ## Solve optimization
        optimize!(m)
        ## Check termination status
        print(
        """

        Termination status: $(termination_status(m))

        """
        )
        ## Dual variable
        global λ_fc = dual.(m.ext[:constraints][:conIECSubmodel2c]) # [EUR/MWh]
        ## Save dual variable, i.e. electricity price for focus country when one extra MW of demand
        global λ_fc_from_iec_submodel_2 = []
        if storage_profiles_based_on_tcs_bm == "yes" || storage_profiles_based_on_tcs_tyndp == "yes" || storage_profiles_based_on_tcs_zero == "yes"
            if storage_profiles_fixed_partly == "no"
                for c in C, jd in JD, jh in JH
                    push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 4))
                end
            elseif storage_profiles_fixed_partly == "yes"
                for c in C, jd in JD, jh in JH
                    if value.(λ_fc[jh,jd,c]) < 1 && value.(λ_fc[jh,jd,c]) > -1
                        push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 2))
                    elseif value.(λ_fc[jh,jd,c]) < 98 && value.(λ_fc[jh,jd,c]) > 94
                        push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 4))
                    elseif value.(λ_fc[jh,jd,c]) < 134 && value.(λ_fc[jh,jd,c]) > 130
                        push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 5))
                    elseif value.(λ_fc[jh,jd,c]) < -7999 && value.(λ_fc[jh,jd,c]) > -8001
                        push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 1))
                    elseif value.(λ_fc[jh,jd,c]) < 8001 && value.(λ_fc[jh,jd,c]) > 7999
                        push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 1))
                    else
                        push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); base = 2, digits = 1))
                    end
                end
            end
        elseif storage_profiles_optimized_endogenously == "yes"
            if reduced_lambdas == "no"
                for c in C, jd in JD, jh in JH
                    push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 4))
                end
            elseif reduced_lambdas == "yes"
                for c in C, jd in JD, jh in JH
                    if value.(λ_fc[jh,jd,c]) < 1 && value.(λ_fc[jh,jd,c]) > -1
                        push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 2))
                    elseif value.(λ_fc[jh,jd,c]) < 98 && value.(λ_fc[jh,jd,c]) > 94
                        push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 4))
                    elseif value.(λ_fc[jh,jd,c]) < 134 && value.(λ_fc[jh,jd,c]) > 130
                        push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 5))
                    elseif value.(λ_fc[jh,jd,c]) < -7999 && value.(λ_fc[jh,jd,c]) > -8001
                        push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 1))
                    elseif value.(λ_fc[jh,jd,c]) < 8001 && value.(λ_fc[jh,jd,c]) > 7999
                        push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); digits = 1))
                    else
                        push!(λ_fc_from_iec_submodel_2, round(value.(λ_fc[jh,jd,c]); base = 2, digits = 1))
                    end
                end
            end
        end
        insertcols!(df_λ, i_countB, string(baseload_level) => λ_fc_from_iec_submodel_2)
        global i_countB = i_countB + 1
        ## Add solve time of adapted model
        global solve_time_count = solve_time_count + solve_time(m)
        global variables_count = variables_count + num_variables(m)
        global constraints_count = constraints_count + num_constraints(m; count_variable_in_set_constraints = true)
        global nonzeros_count = nonzeros_count + MOI.get(m, Gurobi.ModelAttribute("NumNZs"))
    end
    ################################################################################################################################################
    ## Save lambda values for every auxiliary demand level of focus country for every time step: remove '#' in following line code
    #CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","CHECK LAMBDAS BE","λ_FC_iec_sm_2.csv"), df_λ)
    ################################################################################################################################################
    possible_prices_export = m.ext[:ouputs][:possible_prices_export] = []
    possible_prices_import = m.ext[:ouputs][:possible_prices_import] = []
    for baseload in names(df_λ)
        if baseload !== "Timestep"
            for lambda in 1:length(df_λ.Timestep)
                if parse(Float64,baseload) < 0
                    if df_λ[lambda,baseload] ∉ possible_prices_export
                        push!(possible_prices_export, df_λ[lambda,baseload])
                    end
                elseif parse(Float64,baseload) > 0
                    if df_λ[lambda,baseload] ∉ possible_prices_import
                        push!(possible_prices_import, df_λ[lambda,baseload])
                    end
                end
            end
        end
    end
    sort!(possible_prices_export)
    sort!(possible_prices_import)
    lambda_count_export = m.ext[:ouputs][:lambda_count_export] = Dict()
    lambda_count_import = m.ext[:ouputs][:lambda_count_import] = Dict()
    for p_poss_export in possible_prices_export, row in 1:length(df_λ.Timestep)
        lambda_count_export[p_poss_export,df_λ[row,"Timestep"]] = 0    
    end
    for p_poss_import in possible_prices_import, row in 1:length(df_λ.Timestep)
        lambda_count_import[p_poss_import,df_λ[row,"Timestep"]] = 0
    end
    for baseload in names(df_λ)
        if baseload !== "Timestep"
            if parse(Float64,baseload) < 0
                for p_poss_export in possible_prices_export, row in 1:length(df_λ.Timestep)
                    if df_λ[row,baseload] == p_poss_export
                        lambda_count_export[p_poss_export,df_λ[row,"Timestep"]] = lambda_count_export[p_poss_export,df_λ[row,"Timestep"]] + 100 # [MW]
                    end
                end
            elseif parse(Float64,baseload) > 0
                for p_poss_import in possible_prices_import, row in 1:length(df_λ.Timestep)
                    if df_λ[row,baseload] == p_poss_import
                        lambda_count_import[p_poss_import,df_λ[row,"Timestep"]] = lambda_count_import[p_poss_import,df_λ[row,"Timestep"]] + 100 # [MW]
                    end
                end
            end
        end
    end
    ## Save quantities as availability factors in new csv.files
        df_AF_export = DataFrame("Timestep" => TIMES)
        df_AF_import = DataFrame("Timestep" => TIMES)
        i_countC = 2
        for p_poss_export in possible_prices_export
            availability_factor_export = []
            for jd in JD, jh in JH
                push!(availability_factor_export, lambda_count_export[p_poss_export,jh + nTimesteps * (jd - 1)])
            end
            insertcols!(df_AF_export, i_countC, string(p_poss_export) => availability_factor_export)
            global i_countC = i_countC + 1
        end
        i_countD = 2
        for p_poss_import in possible_prices_import
            availability_factor_import = []
            for jd in JD, jh in JH
                push!(availability_factor_import, lambda_count_import[p_poss_import,jh + nTimesteps * (jd - 1)])
            end
            insertcols!(df_AF_import, i_countD, string(p_poss_import) => availability_factor_import)
            global i_countD = i_countD + 1
        end
        if all_direct_neighboring_countries == "yes"
            if all_possible_trade_levels == "yes"
                if storage_profiles_based_on_tcs_bm == "yes"
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","Fixed storage variables","Based on TCS BM","AF_exp_iec_sm_2_fix_stor_var_based_on_tcs_bm.csv"), df_AF_export)
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","Fixed storage variables","Based on TCS BM","AF_imp_iec_sm_2_fix_stor_var_based_on_tcs_bm.csv"), df_AF_import)
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","Fixed storage variables","Based on TCS BM","CompCost_iec_sm_2_fix_stor_var_based_on_tcs_bm.csv"),  DataFrame("Solve time" => solve_time_count, "Variables" => variables_count, "Constraints" => constraints_count, "Nonzeros" => nonzeros_count, "Lambda variables" => length(possible_prices_export) + length(possible_prices_import)))
                elseif storage_profiles_based_on_tcs_tyndp == "yes"
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","Fixed storage variables","Based on TCS TYNDP","AF_exp_iec_sm_2_fix_stor_var_based_on_tcs_tyndp.csv"), df_AF_export)
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","Fixed storage variables","Based on TCS TYNDP","AF_imp_iec_sm_2_fix_stor_var_based_on_tcs_tyndp.csv"), df_AF_import)
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","Fixed storage variables","Based on TCS TYNDP","CompCost_iec_sm_2_fix_stor_var_based_on_tcs_tyndp.csv"),  DataFrame("Solve time" => solve_time_count, "Variables" => variables_count, "Constraints" => constraints_count, "Nonzeros" => nonzeros_count, "Lambda variables" => length(possible_prices_export) + length(possible_prices_import)))
                elseif storage_profiles_based_on_tcs_zero == "yes"
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","Fixed storage variables","Based on TCS ZERO","AF_exp_iec_sm_2_fix_stor_var_based_on_tcs_zero.csv"), df_AF_export)
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","Fixed storage variables","Based on TCS ZERO","AF_imp_iec_sm_2_fix_stor_var_based_on_tcs_zero.csv"), df_AF_import)
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","Fixed storage variables","Based on TCS ZERO","CompCost_iec_sm_2_fix_stor_var_based_on_tcs_zero.csv"),  DataFrame("Solve time" => solve_time_count, "Variables" => variables_count, "Constraints" => constraints_count, "Nonzeros" => nonzeros_count, "Lambda variables" => length(possible_prices_export) + length(possible_prices_import)))
                elseif storage_profiles_optimized_endogenously == "yes"
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","Storage variables optimized endogenously","AF_exp_iec_sm_2_opt_stor_var_endo.csv"), df_AF_export)
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","Storage variables optimized endogenously","AF_imp_iec_sm_2_opt_stor_var_endo.csv"), df_AF_import)
                    CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","Storage variables optimized endogenously","CompCost_iec_sm_2_opt_stor_var_endo.csv"),  DataFrame("Solve time" => solve_time_count, "Variables" => variables_count, "Constraints" => constraints_count, "Nonzeros" => nonzeros_count, "Lambda variables" => length(possible_prices_export) + length(possible_prices_import)))
                end
            end
        elseif all_direct_neighboring_countries == "no"
            #CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","TEST FR","AF_exp_iec_sm_2_test.csv"), df_AF_export)
            #CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","TEST FR","AF_imp_iec_sm_2_test.csv"), df_AF_import)
            #CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 2","TEST FR","CompCost_iec_sm_2_test.csv"),  DataFrame("Solve time" => solve_time_count, "Variables" => variables_count, "Constraints" => constraints_count, "Nonzeros" => nonzeros_count, "Lambda variables" => length(possible_prices_export) + length(possible_prices_import)))
        end
elseif plot_figures == 5
    ## Call variables
    cap_gen = value.(m.ext[:variables][:cap_gen])
    cap_stor = value.(m.ext[:variables][:cap_stor])
    λ = dual.(m.ext[:constraints][:conIECSubmodel1b]) # [EUR/MWh]
    imp = value.(m.ext[:variables][:imp])
    exp = value.(m.ext[:variables][:exp])
    ## Calculate production for considered year
    total_production = m.ext[:ouputs][:total_production] = Dict() # [MWh]
    for i in I
        if i ∈ IV
            total_production[i] = value.(sum(gen[i,jh,jd] + curt[i,jh,jd] for jh in JH, jd in JD))
        else
            total_production[i] = value.(sum(gen[i,jh,jd] for jh in JH, jd in JD))
        end
    end
    ## Calculate total cost for considered year
    total_cost = m.ext[:ouputs][:total_cost] = Dict() # [EUR]
    total_cost["CAPEX"] = sum(IC[i] * cap_gen[i] for i in I) # CAPEX of newly installed generation units
    + sum(ICstor[istor] * cap_stor[istor] for istor in Istor) # CAPEX of newly installed storage units
    total_cost["OPEX"] = sum(VC[id] * gen[id,jh,jd] for id in ID, jh in JH, jd in JD) # OPEX due to dispatchable generation units
    + sum(VOLL * ens[jh,jd] for jh in JH, jd in JD) # OPEX due to not meeting demand
    COMP = ["CAPEX", "OPEX"]
    ## Create column of λ-values
    df_λ_IEC_submodel_1 = DataFrame("Timestep" => TIMES)
    λ_fc_from_iec_submodel_1 = []
    for jd in JD, jh in JH
        push!(λ_fc_from_iec_submodel_1, value.(λ[jh,jd]))
    end
    insertcols!(df_λ_IEC_submodel_1, 2, "Lambda value FC Submodel 1" => λ_fc_from_iec_submodel_1)
    ## Calculate real trade demand in focus country
    df_dtrade_real_fc_IEC_submodel_1 = DataFrame("Timestep" => TIMES)
    dtrade_real_fc_from_iec_submodel_1 = []
    for jd in JD, jh in JH
        push!(dtrade_real_fc_from_iec_submodel_1, (sum(imp[pimp,jh,jd] for pimp in Pimp) - sum(exp[pexp,jh,jd] for pexp in Pexp)))
    end
    insertcols!(df_dtrade_real_fc_IEC_submodel_1, 2, "Real trade demand focus country" => dtrade_real_fc_from_iec_submodel_1)
    ## Create arrays for plotting
    cap_genvec = [cap_gen[i] for i in I]
    cap_storvec = [cap_stor[istor] for istor in Istor]
    productionvec = [total_production[i] for i in I]
    costvec = [total_cost[comp] for comp in COMP]
    ## Get total production, installed generation and storage capacities, and cost components in focus country
    production_fc_from_IEC_submodel_1 = []
    for i in I
        push!(production_fc_from_IEC_submodel_1,total_production[i])
    end
    capacity_generation_fc_from_IEC_submodel_1 = []
    for capacity_generation in value.(cap_gen[:])
        push!(capacity_generation_fc_from_IEC_submodel_1,capacity_generation)
    end
    capacity_storage_fc_from_IEC_submodel_1 = []
    for capacity_storage in value.(cap_stor[:])
        push!(capacity_storage_fc_from_IEC_submodel_1,capacity_storage)
    end
    cost_fc_from_IEC_submodel_1 = []
    for comp in COMP
        push!(cost_fc_from_IEC_submodel_1,total_cost[comp])
    end
    ## Save results of focus country from IEC Submodel 1 in csv.file
    if storage_unit_investments_allowed == "no"
        if storage_profiles_based_on_tcs_bm == "yes"
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS BM","Cap_Prod_FC_iec_sm_1_no_stor_tcs_bm.csv"),  DataFrame("Generation unit" => I, "Capacity" => capacity_generation_fc_from_IEC_submodel_1, "Production" => production_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS BM","Cost_Comp_FC_iec_sm_1_no_stor_tcs_bm.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS BM","λ_FC_iec_sm_1_no_stor_tcs_bm.csv"), df_λ_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS BM","Dtrade_real_FC_iec_sm_1_no_stor_tcs_bm.csv"), df_dtrade_real_fc_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS BM","CompCost_iec_sm_1_no_stor_tcs_bm.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        elseif storage_profiles_based_on_tcs_tyndp == "yes"
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS TYNDP","Cap_Prod_FC_iec_sm_1_no_stor_tcs_tyndp.csv"),  DataFrame("Generartion unit" => I, "Capacity" => capacity_generation_fc_from_IEC_submodel_1, "Production" => production_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS TYNDP","Cost_Comp_FC_iec_sm_1_no_stor_tcs_tyndp.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS TYNDP","λ_FC_iec_sm_1_no_stor_tcs_tyndp.csv"), df_λ_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS TYNDP","Dtrade_real_FC_iec_sm_1_no_stor_tcs_tyndp.csv"), df_dtrade_real_fc_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS TYNDP","CompCost_iec_sm_1_no_stor_tcs_tyndp.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        elseif storage_profiles_based_on_tcs_zero == "yes"
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS ZERO","Cap_Prod_FC_iec_sm_1_no_stor_tcs_zero.csv"),  DataFrame("Generation unit" => I, "Capacity" => capacity_generation_fc_from_IEC_submodel_1, "Production" => production_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS ZERO","Cost_Comp_FC_iec_sm_1_no_stor_tcs_zero.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS ZERO","λ_FC_iec_sm_1_no_stor_tcs_zero.csv"), df_λ_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS ZERO","Dtrade_real_FC_iec_sm_1_no_stor_tcs_zero.csv"), df_dtrade_real_fc_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS ZERO","CompCost_iec_sm_1_no_stor_tcs_zero.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        elseif storage_profiles_optimized_endogenously == "yes"
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS NO FIXING","Cap_Prod_FC_iec_sm_1_no_stor_tcs_no_fix.csv"),  DataFrame("Generation unit" => I, "Capacity" => capacity_generation_fc_from_IEC_submodel_1, "Production" => production_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS NO FIXING","Cost_Comp_FC_iec_sm_1_no_stor_tcs_no_fix.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS NO FIXING","λ_FC_iec_sm_1_no_stor_tcs_no_fix.csv"), df_λ_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS NO FIXING","Dtrade_real_FC_iec_sm_1_no_stor_tcs_no_fix.csv"), df_dtrade_real_fc_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS NO FIXING","CompCost_iec_sm_1_no_stor_tcs_no_fix.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        end
    elseif storage_unit_investments_allowed == "yes"
        if storage_profiles_based_on_tcs_bm == "yes"
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS BM","CapGen_Prod_FC_iec_sm_1_stor_tcs_bm.csv"),  DataFrame("Generation unit" => I, "Capacity" => capacity_generation_fc_from_IEC_submodel_1, "Production" => production_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS BM","CapStor_FC_iec_sm_1_stor_tcs_bm.csv"),  DataFrame("Storage unit" => Istor, "Capacity" => capacity_storage_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS BM","Cost_Comp_FC_iec_sm_1_stor_tcs_bm.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS BM","λ_FC_iec_sm_1_stor_tcs_bm.csv"), df_λ_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS BM","Dtrade_real_FC_iec_sm_1_stor_tcs_bm.csv"), df_dtrade_real_fc_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS BM","CompCost_iec_sm_1_stor_tcs_bm.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        elseif storage_profiles_based_on_tcs_tyndp == "yes"
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS TYNDP","CapGen_Prod_FC_iec_sm_1_stor_tcs_tyndp.csv"),  DataFrame("Generation unit" => I, "Capacity" => capacity_generation_fc_from_IEC_submodel_1, "Production" => production_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS TYNDP","CapStor_FC_iec_sm_1_stor_tcs_tyndp.csv"),  DataFrame("Storage unit" => Istor, "Capacity" => capacity_storage_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS TYNDP","Cost_Comp_FC_iec_sm_1_stor_tcs_tyndp.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS TYNDP","λ_FC_iec_sm_1_stor_tcs_tyndp.csv"), df_λ_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS TYNDP","Dtrade_real_FC_iec_sm_1_stor_tcs_tyndp.csv"), df_dtrade_real_fc_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS TYNDP","CompCost_iec_sm_1_stor_tcs_tyndp.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        elseif storage_profiles_based_on_tcs_zero == "yes"
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS ZERO","CapGen_Prod_FC_iec_sm_1_stor_tcs_zero.csv"),  DataFrame("Generation unit" => I, "Capacity" => capacity_generation_fc_from_IEC_submodel_1, "Production" => production_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS ZERO","CapStor_FC_iec_sm_1_stor_tcs_zero.csv"),  DataFrame("Storage unit" => Istor, "Capacity" => capacity_storage_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS ZERO","Cost_Comp_FC_iec_sm_1_stor_tcs_zero.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS ZERO","λ_FC_iec_sm_1_stor_tcs_zero.csv"), df_λ_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS ZERO","Dtrade_real_FC_iec_sm_1_stor_tcs_zero.csv"), df_dtrade_real_fc_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS ZERO","CompCost_iec_sm_1_stor_tcs_zero.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        elseif storage_profiles_optimized_endogenously == "yes"
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS NO FIXING","CapGen_Prod_FC_iec_sm_1_stor_tcs_no_fix.csv"),  DataFrame("Generation unit" => I, "Capacity" => capacity_generation_fc_from_IEC_submodel_1, "Production" => production_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS NO FIXING","CapStor_FC_iec_sm_1_stor_tcs_no_fix.csv"),  DataFrame("Storage unit" => Istor, "Capacity" => capacity_storage_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS NO FIXING","Cost_Comp_FC_iec_sm_1_stor_tcs_no_fix.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_1))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS NO FIXING","λ_FC_iec_sm_1_stor_tcs_no_fix.csv"), df_λ_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS NO FIXING","Dtrade_real_FC_iec_sm_1_stor_tcs_no_fix.csv"), df_dtrade_real_fc_IEC_submodel_1)
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS NO FIXING","CompCost_iec_sm_1_stor_tcs_no_fix.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        end
    end
elseif plot_figures == 6
    fc_name = "BE00"
    ## Output data (lambda values in focus country) from IEC Submodel 1 (without and with storage unit investments for TCS-NO FIXING, TCS-BM, TCS-TYNDP and TCS-ZERO)
    if storage_unit_investments_allowed == "no"
        if storage_profiles_optimized_endogenously == "yes" # TCS_NO_FIXING
            λ_IEC_sm_1 =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS NO FIXING","λ_FC_iec_sm_1_no_stor_tcs_no_fix.csv"),DataFrame)
        elseif storage_profiles_based_on_tcs_bm == "yes" # TCS_BM
            λ_IEC_sm_1 =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS BM","λ_FC_iec_sm_1_no_stor_tcs_bm.csv"),DataFrame)
        elseif storage_profiles_based_on_tcs_tyndp == "yes" # TCS_TYNDP
            λ_IEC_sm_1 =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS TYNDP","λ_FC_iec_sm_1_no_stor_tcs_tyndp.csv"),DataFrame)
        elseif storage_profiles_based_on_tcs_zero == "yes" # TCS_ZERO
            λ_IEC_sm_1 =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","Without storage unit investments","Based on TCS ZERO","λ_FC_iec_sm_1_no_stor_tcs_zero.csv"),DataFrame)
        end
    elseif storage_unit_investments_allowed == "yes"
        if storage_profiles_optimized_endogenously == "yes" # TCS_NO_FIXING
            λ_IEC_sm_1 =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS NO FIXING","λ_FC_iec_sm_1_stor_tcs_no_fix.csv"),DataFrame)
        elseif storage_profiles_based_on_tcs_bm == "yes" # TCS_BM
            λ_IEC_sm_1 =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS BM","λ_FC_iec_sm_1_stor_tcs_bm.csv"),DataFrame)
        elseif storage_profiles_based_on_tcs_tyndp == "yes" # TCS_TYNDP
            λ_IEC_sm_1 =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS TYNDP","λ_FC_iec_sm_1_stor_tcs_tyndp.csv"),DataFrame)
        elseif storage_profiles_based_on_tcs_zero == "yes" # TCS_ZERO
            λ_IEC_sm_1 =  CSV.read(joinpath(@__DIR__,"OutputData","IEC submodel 1","With storage unit investments","Based on TCS ZERO","λ_FC_iec_sm_1_stor_tcs_zero.csv"),DataFrame)
        end
    end
    λ_sm1 = [λ_IEC_sm_1[jh + nTimesteps * (jd - 1),"Lambda value FC Submodel 1"] for jh in JH, jd in JD]
    ## Call variables
    flow = value.(m.ext[:variables][:flow])
    λ = dual.(m.ext[:constraints][:conIECSubmodel2b])
    ## Calculate total import of focus country for considered year
    total_import = m.ext[:ouputs][:total_import] = Dict() # [MWh]
    total_export = m.ext[:ouputs][:total_export] = Dict() # [MWh]
    for c in C
        total_import[c] = sum(max(T[c,l]*flow[l,jh,jd],0) for l in LinescdVector, jh in JH, jd in JD)
        total_export[c] = sum(max(-T[c,l]*flow[l,jh,jd],0) for l in LinescdVector, jh in JH, jd in JD)
    end
    ## Calculate total cost for considered year
    total_cost = m.ext[:ouputs][:total_cost] = Dict() # [EUR]
    for c in C
        total_cost["Import"] = sum(λ_sm1[jh,jd] * max(T[c,l]*flow[l,jh,jd],0) for l in LinescdVector, jh in JH, jd in JD) # Import cost
        total_cost["Export"] = -sum(λ_sm1[jh,jd] * max(-T[c,l]*flow[l,jh,jd],0) for l in LinescdVector, jh in JH, jd in JD) # Export Revenue
        total_cost["Congestion"] = -sum(abs((λ_sm1[jh,jd] - λ[jh,jd,cdonly])/2 * T[c,l] * T[cdonly,l] * flow[l,jh,jd]) for l in LinescdVector, jh in JH, jd in JD, cdonly in CDonly) # Congestion rents
    end
    COMP = ["Import", "Export", "Congestion"]
    ## Create arrays for plotting
    impvec = [total_import[c] for c in C]
    expvec = [total_export[c] for c in C]
    costvec = [total_cost[comp] for comp in COMP]
    ## Get cost components in focus country
    cost_fc_from_IEC_submodel_4 = []
    for comp in COMP
        push!(cost_fc_from_IEC_submodel_4,total_cost[comp])
    end
    ## Save total import and export, and three cost components in focus country in csv.files
    if storage_unit_investments_allowed == "no"
        if storage_profiles_optimized_endogenously == "yes" # TCS_NO_FIXING
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","Without storage unit investments","Based on TCS NO FIXING","Imp_Exp_FC_iec_sm_4_no_stor_tcs_no_fix.csv"),  DataFrame("Import" => total_import[fc_name], "Export" => total_export[fc_name]))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","Without storage unit investments","Based on TCS NO FIXING","Cost_Comp_FC_iec_sm_4_no_stor_tcs_no_fix.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_4))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","Without storage unit investments","Based on TCS NO FIXING","CompCost_iec_sm_4_no_stor_tcs_no_fix.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        elseif storage_profiles_based_on_tcs_bm == "yes" # TCS_BM
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","Without storage unit investments","Based on TCS BM","Imp_Exp_FC_iec_sm_4_no_stor_tcs_bm.csv"),  DataFrame("Import" => total_import[fc_name], "Export" => total_export[fc_name]))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","Without storage unit investments","Based on TCS BM","Cost_Comp_FC_iec_sm_4_no_stor_tcs_bm.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_4))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","Without storage unit investments","Based on TCS BM","CompCost_iec_sm_4_no_stor_tcs_bm.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        elseif storage_profiles_based_on_tcs_tyndp == "yes" # TCS_TYNDP
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","Without storage unit investments","Based on TCS TYNDP","Imp_Exp_FC_iec_sm_4_no_stor_tcs_tyndp.csv"),  DataFrame("Import" => total_import[fc_name], "Export" => total_export[fc_name]))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","Without storage unit investments","Based on TCS TYNDP","Cost_Comp_FC_iec_sm_4_no_stor_tcs_tyndp.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_4))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","Without storage unit investments","Based on TCS TYNDP","CompCost_iec_sm_4_no_stor_tcs_tyndp.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        elseif storage_profiles_based_on_tcs_zero == "yes" # TCS_ZERO
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","Without storage unit investments","Based on TCS ZERO","Imp_Exp_FC_iec_sm_4_no_stor_tcs_zero.csv"),  DataFrame("Import" => total_import[fc_name], "Export" => total_export[fc_name]))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","Without storage unit investments","Based on TCS ZERO","Cost_Comp_FC_iec_sm_4_no_stor_tcs_zero.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_4))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","Without storage unit investments","Based on TCS ZERO","CompCost_iec_sm_4_no_stor_tcs_zero.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        end
    elseif storage_unit_investments_allowed == "yes"
        if storage_profiles_optimized_endogenously == "yes" # TCS_NO_FIXING
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","With storage unit investments","Based on TCS NO FIXING","Imp_Exp_FC_iec_sm_4_stor_tcs_no_fix.csv"),  DataFrame("Import" => total_import[fc_name], "Export" => total_export[fc_name]))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","With storage unit investments","Based on TCS NO FIXING","Cost_Comp_FC_iec_sm_4_stor_tcs_no_fix.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_4))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","With storage unit investments","Based on TCS NO FIXING","CompCost_iec_sm_4_stor_tcs_no_fix.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        elseif storage_profiles_based_on_tcs_bm == "yes" # TCS_BM
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","With storage unit investments","Based on TCS BM","Imp_Exp_FC_iec_sm_4_stor_tcs_bm.csv"),  DataFrame("Import" => total_import[fc_name], "Export" => total_export[fc_name]))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","With storage unit investments","Based on TCS BM","Cost_Comp_FC_iec_sm_4_stor_tcs_bm.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_4))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","With storage unit investments","Based on TCS BM","CompCost_iec_sm_4_stor_tcs_bm.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        elseif storage_profiles_based_on_tcs_tyndp == "yes" # TCS_TYNDP
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","With storage unit investments","Based on TCS TYNDP","Imp_Exp_FC_iec_sm_4_stor_tcs_tyndp.csv"),  DataFrame("Import" => total_import[fc_name], "Export" => total_export[fc_name]))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","With storage unit investments","Based on TCS TYNDP","Cost_Comp_FC_iec_sm_4_stor_tcs_tyndp.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_4))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","With storage unit investments","Based on TCS TYNDP","CompCost_iec_sm_4_stor_tcs_tyndp.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        elseif storage_profiles_based_on_tcs_zero == "yes" # TCS_ZERO
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","With storage unit investments","Based on TCS ZERO","Imp_Exp_FC_iec_sm_4_stor_tcs_zero.csv"),  DataFrame("Import" => total_import[fc_name], "Export" => total_export[fc_name]))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","With storage unit investments","Based on TCS ZERO","Cost_Comp_FC_iec_sm_4_stor_tcs_zero.csv"),  DataFrame("Cost Component" => COMP, "Value" => cost_fc_from_IEC_submodel_4))
            CSV.write(joinpath(@__DIR__,"OutputData","IEC submodel 4","With storage unit investments","Based on TCS ZERO","CompCost_iec_sm_4_stor_tcs_zero.csv"),  DataFrame("Solve time" => solve_time(m), "Variables" => num_variables(m), "Constraints" => num_constraints(m; count_variable_in_set_constraints = true), "Nonzeros" => MOI.get(m, Gurobi.ModelAttribute("NumNZs"))))
        end
    end
end