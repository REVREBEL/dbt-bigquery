# File: setup.sh
#!/bin/bash

# 1. Install dbt packages (including dbt-utils and agent-skills)
dbt deps

# 2. Dynamic Update: Pull new columns from BigQuery into YAML
# This detects new columns like "rev_otb_chg_90" and populates docs
dbt-osmosis yaml refactor --project-dir. --profiles-dir. --auto-apply 

# 3. Searchable Definitions: Generate metadata for the UI
dbt docs generate 

echo "Environment initialized. Dynamic schema updates complete."