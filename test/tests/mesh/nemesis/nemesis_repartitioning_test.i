[Mesh]
  file = cylinder/cylinder.e
  nemesis = true
  # leaving skip_partitioning off lets us exodiff against a gold
  # standard generated with default libMesh settings
  # skip_partitioning = true
[]

[Variables]
  active = 'u'

  [./u]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Kernels]
  active = 'diff'

  [./diff]
    type = Diffusion
    variable = u
  [../]
[]

[BCs]
  active = 'left right'

  [./left]
    type = DirichletBC
    variable = u
    boundary = 1
    value = 0
  [../]

  [./right]
    type = DirichletBC
    variable = u
    boundary = 2
    value = 1
  [../]
[]

[Postprocessors]
  [./elem_avg]
    type = ElementAverageValue
    variable = u
  [../]
[]

[Executioner]
  type = Steady

  # Preconditioned JFNK (default)
  solve_type = 'PJFNK'
[]

[Outputs]
  file_base = repartitioned
  output_initial = true
  nemesis = true
  print_linear_residuals = true
  print_perf_log = true
[]