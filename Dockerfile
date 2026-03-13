# File: Dockerfile
FROM ghcr.io/dbt-labs/dbt-bigquery:1.9.latest

# Switch to root to install system dependencies
USER root
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    && rm -rf /var/lib/apt/lists/*

RUN dbt --version || which dbt || ls -la /usr/local/bin

# 1. Install dbt Fusion Engine Binary
# The official script fetches the high-performance Rust binary
ENV PATH="/root/.local/bin:${PATH}"

#RUN curl -fsSL -o /tmp/dbt-install.sh https://public.cdn.getdbt.com/fs/install/install.sh \
#
# && chmod +x /tmp/dbt-install.sh \
# && /bin/sh /tmp/dbt-install.sh \
# && dbtf --version
 
# 2. Setup Project Directory
WORKDIR /usr/app/dbt_project

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:${PATH}"

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# 3. Install Python Utilities
# dbt-osmosis: For dynamic schema syncing
# metricflow: For the semantic layer (Searchable Definitions)
# dbt-mcp: For AI integration (Model Context Protocol)
RUN pip install --no-cache-dir \
    uv \
    dbt-mcp \
    dbt-osmosis \
    "dbt-metricflow[dbt-bigquery]"

COPY . .

ENV DBT_PROFILES_DIR=/usr/app/dbt_project
ENV GOOGLE_APPLICATION_CREDENTIALS=/usr/app/dbt_project/gcp-key.json

# Provide an unambiguous alias for the Fusion engine
RUN ln -s /usr/local/bin/dbt /usr/local/bin/dbtf

ENTRYPOINT ["tail", "-f", "/dev/null"]