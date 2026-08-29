FROM node:24-trixie-slim

WORKDIR /app

RUN npm install -g mcp-searxng@latest && \
    npm cache clean --force

EXPOSE 3000

# RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD curl -f http://localhost:${MCP_HTTP_PORT:-3000}/health || exit 1

CMD ["sh", "-c", "SEARXNG_URL=${SEARXNG_URL:-http://searxng:8888} MCP_HTTP_HOST=${MCP_HTTP_PORT:-0.0.0.0} MCP_HTTP_PORT=${MCP_HTTP_PORT:-3000} mcp-searxng"]


