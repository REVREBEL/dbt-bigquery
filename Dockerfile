# File: Dockerfile
FROM ghcr.io/dbt-labs/bigquery:latest

# Switch to root to install system dependencies
USER root
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    && rm -rf /var/lib/apt/lists/*

# 1. Install dbt Fusion Engine Binary
# The official script fetches the high-performance Rust binary
RUN curl -fsSL https://public.cdn.getdbt.com/fs/install/install.sh | sh -s -- --update

# 2. Install Python Utilities
# dbt-osmosis: For dynamic schema syncing
# metricflow: For the semantic layer (Searchable Definitions)
# dbt-mcp: For AI integration (Model Context Protocol)
RUN pip install --no-cache-dir \
    dbt-osmosis \
    metricflow \
    dbt-mcp \
    uv

# 3. Setup Project Directory
WORKDIR /usr/app/dbt

# FIXED: Corrected the COPY instruction with proper spacing
COPY . .

# Environment setup for profiles and credentials
ENV DBT_PROFILES_DIR=/usr/app/dbt
ENV GOOGLE_APPLICATION_CREDENTIALS=/usr/app/dbt/gcp-key.json

# Provide an unambiguous alias for the Fusion engine
RUN ln -s /usr/local/bin/dbt /usr/local/bin/dbtf

# Keep the container running for development
ENTRYPOINT ["tail", "-f", "/dev/null"]