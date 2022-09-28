# list all pipelines from a project
az pipelines list --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes'

# create Dev pipelines
az pipelines create --name 'CI-Dev-StoragePublicApi' --folder-path '/StoragePublicApi' --branch 'develop' --yaml-path '/OfficeHoursApi.Storage.Public/deployment/devops-pipelines/dev-ci.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 
az pipelines create --name 'CD-Dev-StoragePublicApi' --folder-path '/StoragePublicApi' --branch 'develop' --yaml-path '/OfficeHoursApi.Storage.Public/deployment/devops-pipelines/dev-cd.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 

# create Infra CD pipeline for Test & Prod
az pipelines create --name 'CD-Infra-StoragePublicApi' --folder-path '/StoragePublicApi' --branch 'main' --yaml-path '/OfficeHoursApi.Storage.Public/deployment/devops-pipelines/cd-infra.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 

# create App CD pipeline for Test & Prod
az pipelines create --name 'CD-App-StoragePublicApi' --folder-path '/StoragePublicApi' --branch 'main' --yaml-path '/OfficeHoursApi.Storage.Public/deployment/devops-pipelines/cd-app.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 
