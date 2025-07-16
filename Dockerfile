FROM ghcr.io/cyreneai/base-mcp:latest

WORKDIR /app

# Install your service dependencies
COPY requirements.txt .  
RUN pip install --no-cache-dir -r requirements.txt

# Copy in your service code
COPY server.py .

# Set environment variables for Kubernetes deployment
ENV LOCAL_MODE="false"
ENV FASTMCP_BASE_URL="http://fastmcp-core-svc:9000"
ENV BOT_API_BASE_URL="http://localhost:8000"

# Standard MCP port in Kubernetes
EXPOSE 9003

CMD ["uvicorn", "mcp-servers.telegram-mcp.server:app", "--host", "0.0.0.0", "--port", "9003"]
