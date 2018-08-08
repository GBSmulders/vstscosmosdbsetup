<#
.SYNOPSIS
Checks a Cosmos DB if a given database, and collections within, exist and creates them if they aren't

.DESCRIPTION
This script will check the Cosmos DB for availability of the database.
If that doesn't exits, it will attempt to create it.

After that, it will check of the given collections exist withing that database.
If not, it will attempt to create those.

.PARAMETER cosmosDbName
The account name of the Cosmos DB

.PARAMETER resourceGroup
The name of the resourcegroup in which this the Cosmos DB is placed

.PARAMETER databaseName
The name of the database within the Cosmos DB

.PARAMETER collectionNames
A string array with collection names to check or create within the database

.PARAMETER principalUser
Service pricipal user used to login

.PARAMETER collectionNames
Password for the service principal

.PARAMETER collectionNames
Tennant of the service principal
*Hint: Run the following command in the Azure CLI to retrieve the tennant:
  az account show --query 'tenantId'

.EXAMPLE
./SetupCollection.ps1 -cosmosDbName "MyCosmosDB" -resourceGroup "MyCosmosDBResourceGroup" -databaseName "MyCosmosDBDatabase" -collectionName "Collection1"

.EXAMPLE
./SetupCollection.ps1 -cosmosDbName "MyCosmosDB" -resourceGroup "MyCosmosDBResourceGroup" -databaseName "MyCosmosDBDatabase" -collectionName "Collection1","Colleciton2"

.NOTES
Work still to do:
- Collection properties
#>

param([string]$cosmosDbName
     ,[string]$resourceGroup
     ,[string]$databaseName
     ,[string[]]$collectionNames
     ,[string]$principalUser
     ,[string]$principalPassword
     ,[string]$principalTennant)

Write-Output "Loggin in with Service Principal $servicePrincipal"
az login --service-principal -u $principalUser -p $principalPassword -t $principalTennant

Write-Output "Check if database exists: $databaseName"
if ((az cosmosdb database exists -d $databaseName -n $cosmosDbName -g $resourceGroup) -ne "true")
{
  Write-Output "Creating database: $databaseName"
  az cosmosdb database create -d $databaseName -n $cosmosDbName -g $resourceGroup
}

foreach ($collectionName in $collectionNames)
{
  Write-Output "Check if collection exists: $collectionName"
  if ((az cosmosdb collection exists -c $collectionName -d $databaseName -n $cosmosDbName -g $resourceGroup) -ne "true")
  {
    Write-Output "Creating collection: $collectionName"
    az cosmosdb collection create -c $collectionName -d $databaseName -n $cosmosDbName -g $resourceGroup
  }
}

Write-Output "List Collections"
az cosmosdb collection list -d $databaseName -n $cosmosDbName -g $resourceGroup