[Mesh]
  type = FileMesh
  file = bh07_input.e
[]

[GlobalParams]
  porepressureNames_UO = PPNames
[]

[UserObjects]
  [./PPNames]
    type = RichardsPorepressureNames
    porepressure_vars = pressure
  [../]
  [./DensityConstBulk]
    type = RichardsDensityConstBulk
    dens0 = 1000
    bulk_mod = 2E9
  [../]
  [./Seff1VG]
    type = RichardsSeff1VG
    m = 0.8
    al = 1E-5
  [../]
  [./RelPermPower]
    type = RichardsRelPermPower
    simm = 0.0
    n = 2
  [../]
  [./Saturation]
    type = RichardsSat
    s_res = 0
    sum_s_res = 0
  [../]
  [./SUPGstandard]
    type = RichardsSUPGstandard
    p_SUPG = 1E8
  [../]

  [./borehole_total_outflow_mass]
    type = RichardsSumQuantity
  [../]
[]


[Variables]
  active = 'pressure'
  [./pressure]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[ICs]
  [./p_ic]
    type = FunctionIC
    variable = pressure
    function = initial_pressure
  [../]
[]

[BCs]
  [./fix_outer]
    type = DirichletBC
    boundary = perimeter
    variable = pressure
    value = 1E7
  [../]
[]

[AuxVariables]
  [./Seff1VG_Aux]
  [../]
[]


[Kernels]
  active = 'richardsf richardst'
  [./richardst]
    type = RichardsMassChange
    variable = pressure
  [../]
  [./richardsf]
    type = RichardsFlux
    variable = pressure
  [../]
[]

[DiracKernels]
  [./bh]
    type = RichardsBorehole
    bottom_pressure = 0
    point_file = bh07.bh
    SumQuantityUO = borehole_total_outflow_mass
    variable = pressure
    unit_weight = '0 0 0'
    re_constant = 0.1594
    character = 2 # this is to make the length=1 borehole fill the entire z=2 height
    mesh_adaptivity = false
    MyNameIsAndyWilkins = false
  [../]
[]


[Postprocessors]
  [./bh_report]
    type = RichardsPlotQuantity
    uo = borehole_total_outflow_mass
  [../]

  [./fluid_mass]
    type = RichardsMass
    variable = pressure
  [../]
[]


[Functions]
  [./initial_pressure]
    type = ParsedFunction
    value = 1E7
  [../]
[]


[Materials]
  [./all]
    type = RichardsMaterial
    block = 1
    viscosity = 1E-3
    mat_porosity = 0.1
    mat_permeability = '1E-11 0 0  0 1E-11 0  0 0 1E-11'
    density_UO = DensityConstBulk
    relperm_UO = RelPermPower
    sat_UO = Saturation
    seff_UO = Seff1VG
    SUPG_UO = SUPGstandard
    gravity = '0 0 0'
    linear_shape_fcns = true
  [../]
[]

[AuxKernels]
  [./Seff1VG_AuxK]
    type = RichardsSeffAux
    variable = Seff1VG_Aux
    seff_UO = Seff1VG
    pressure_vars = pressure
  [../]
[]


[Preconditioning]
  [./usual]
    type = SMP
    full = true
    petsc_options = '-snes_converged_reason'
    petsc_options_iname = '-ksp_type -pc_type -snes_atol -snes_rtol -snes_max_it -ksp_max_it'
    petsc_options_value = 'bcgs bjacobi 1E-10 1E-10 10000 30'
  [../]
[]


[Executioner]
  type = Transient
  end_time = 1000
  solve_type = NEWTON

  [./TimeStepper]
    # get only marginally better results for smaller time steps
    type = FunctionDT
    time_dt = '1000 10000'
    time_t = '100 1000'
  [../]

[]

[Output]
  file_base = bh07
  output_initial = true
  interval = 10000
  exodus = true
  perf_log = true
  linear_residuals = false
  postprocessor_csv = false
[]