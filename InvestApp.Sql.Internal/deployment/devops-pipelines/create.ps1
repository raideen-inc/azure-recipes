# create Dev pipelines
az pipelines create --name 'CI-Dev-SqlInternalWeb' --folder-path '/SqlInternalWeb' --branch 'develop' --yaml-path '/InvestApp.Sql.Internal/deployment/devops-pipelines/dev-ci.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 
az pipelines create --name 'CD-Dev-SqlInternalWeb' --folder-path '/SqlInternalWeb' --branch 'develop' --yaml-path '/InvestApp.Sql.Internal/deployment/devops-pipelines/dev-cd.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 

# create Infra CD pipeline for Test & Prod
az pipelines create --name 'CD-Infra-SqlInternalWeb' --folder-path '/SqlInternalWeb' --branch 'main' --yaml-path '/InvestApp.Sql.Internal/deployment/devops-pipelines/cd-infra.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 

# create App CD pipeline for Test & Prod
az pipelines create --name 'CD-App-SqlInternalWeb' --folder-path '/SqlInternalWeb' --branch 'main' --yaml-path '/InvestApp.Sql.Internal/deployment/devops-pipelines/cd-app.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 
