# create Dev pipelines
az pipelines create --name 'CI-Dev-SqlRestrictedApi' --folder-path '/SqlRestrictedApi' --branch 'develop' --yaml-path '/OfficeHoursApi.Sql.Restricted/deployment/devops-pipelines/dev-ci.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 
az pipelines create --name 'CD-Dev-SqlRestrictedApi' --folder-path '/SqlRestrictedApi' --branch 'develop' --yaml-path '/OfficeHoursApi.Sql.Restricted/deployment/devops-pipelines/dev-cd.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 

# create Infra CD pipeline for Test & Prod
az pipelines create --name 'CD-Infra-SqlRestrictedApi' --folder-path '/SqlRestrictedApi' --branch 'main' --yaml-path '/OfficeHoursApi.Sql.Restricted/deployment/devops-pipelines/cd-infra.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 

# create App CD pipeline for Test & Prod
az pipelines create --name 'CD-App-SqlRestrictedApi' --folder-path '/SqlRestrictedApi' --branch 'main' --yaml-path '/OfficeHoursApi.Sql.Restricted/deployment/devops-pipelines/cd-app.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 
