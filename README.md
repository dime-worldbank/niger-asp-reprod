# niger-asp-reprod
This repository contains reproducibility code for the paper “Tackling Psychosocial and Capital Constraints Opens Pathways out of Poverty.”

Data is posted in the World Bank Microdata Library at: https://microdata.worldbank.org/index.php/catalog/4294.

## Code Structure
<pre>
niger-asp-reprod  
├───Baseline  
│   ├───cost_benefit
│   │   └───NER
│   │       └───ASPP_Productive_costing_Niger_2020.xlsx  
│   └───Output  
│       └───NER  
│           └───balance  
└───Joint  
    ├───Do  
    │   ├───04_my_programs
    │   │   ├───03_regs
    │   │   └───04_general
    │   └───NER
    └───Output
        └───NER
            ├───report_graphs
            ├───report_stats
            └───report_tables
                └───vertical
                    └───interim
</pre>


## Data Structure
<pre>

Sahel_analysis
├───Followup
│   └───Data
│       └───NER
│           └───05_Regstats
├───Followup_2
│   └───Data
│       └───NER
│           └───05_Regstats
│               └───mht
└───Joint
    └───Data
        ├───allrounds_NER_food.dta
        ├───allrounds_NER_hh.dta
        └───baseline_NER_hh.dta
</pre>

## Replication Steps
To run the scripts, run the "00_master_ner.do" file at "niger-asp-reprod/Joint/Do/NER" after changing the first two paths as described in that file.

