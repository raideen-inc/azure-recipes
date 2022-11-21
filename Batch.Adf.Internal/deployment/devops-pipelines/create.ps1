az devops configure --defaults organization=https://dev.azure.com/raideen-demo project=Azure$20Recipes

# create Dev pipelines
az pipelines create --name 'CI-Dev-BatchAdfInternal' --folder-path '/BatchAdfInternal' --branch 'develop' --yaml-path '/Batch.Adf.Internal/deployment/devops-pipelines/dev-ci.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 
az pipelines create --name 'CD-Dev-BatchAdfInternal' --folder-path '/BatchAdfInternal' --branch 'develop' --yaml-path '/Batch.Adf.Internal/deployment/devops-pipelines/dev-cd.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 
az pipelines create --name 'CD-Dev-BatchAdfInternal-Infra' --folder-path '/BatchAdfInternal' --branch 'develop' --yaml-path '/Batch.Adf.Internal/deployment/devops-pipelines/dev-cd-infra.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 


# create Infra CD pipeline for Test & Prod
az pipelines create --name 'CD-Infra-BatchAdfInternal' --folder-path '/BatchAdfInternal' --branch 'main' --yaml-path '/Batch.Adf.Internal/deployment/devops-pipelines/cd-infra.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 

# create App CD pipeline for Test & Prod
az pipelines create --name 'CD-App-BatchAdfInternal' --folder-path '/BatchAdfInternal' --branch 'main' --yaml-path '/Batch.Adf.Internal/deployment/devops-pipelines/cd-app.yaml' --organization 'https://dev.azure.com/raideen-demo' --project 'Azure Recipes' --repository 'https://dev.azure.com/raideen-demo/Azure Recipes/_git/Azure Recipes' 
