# Stage 1: Build stage
FROM python:3.11-slim AS build

WORKDIR /app

# Install build dependencies and Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Production stage
FROM python:3.11-slim

WORKDIR /app

# Copy only the necessary files
COPY --from=build /app /app/
COPY . /app/

# Create a non-root user for security
RUN adduser --disabled-password --gecos '' myuser
USER myuser

# Expose the port your app runs on
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
