FROM ghcr.io/cyreneai/base-mcp:latest

WORKDIR /app

# Install your service dependencies
COPY requirements.txt .  
RUN pip install --no-cache-dir -r requirements.txt

# Copy in your service code
COPY server.py .

EXPOSE 9003

CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "9003"]
