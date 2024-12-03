# My Python App

## Steps to Deploy

1. Clone the repository.
2. Build and push the Docker image.
3. Provision Azure resources using Terraform.
4. Deploy the Docker container to Azure App Service.
5. Set up CI/CD pipeline.

## Accessing the Deployed Service

- URL: http://pyappservice.com

## Considerations

- **High Availability:** Resources are provisioned across multiple availability zones if applicable for each resource.
- **Networking:** The app is within a VNet for private networking.
- **Security:** Secrets are stored securely in the CI/CD pipeline.  
