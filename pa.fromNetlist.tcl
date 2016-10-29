
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name CPU_RAM_Experiment -dir "D:/Study/THU/2016Autumn/CPU/CPU_RAM_Experiment/planAhead_run_3" -part xc3s1200efg320-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "D:/Study/THU/2016Autumn/CPU/CPU_RAM_Experiment/Main.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/Study/THU/2016Autumn/CPU/CPU_RAM_Experiment} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "Main.ucf" [current_fileset -constrset]
add_files [list {Main.ucf}] -fileset [get_property constrset [current_run]]
link_design
