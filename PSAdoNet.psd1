@{

  # Script module or binary module file associated with this manifest.
  RootModule = 'PSAdoNet.psm1'
  
  # Version number of this module.
  ModuleVersion = '1.0'
  
  # ID used to uniquely identify this module
  GUID = 'b951295b-6699-482b-8962-89a080d4cb8e'
  
  # Author of this module
  Author = 'Pim Brouwers'
  
  # Company or vendor of this module
  CompanyName = ''
  
  # Copyright statement for this module
  Copyright = '(c) 2019 Pim Brouwers. All rights reserved.'
  
  # Description of the functionality provided by this module
  Description = 'ADO.NET for all'
  
  # Minimum version of the Windows PowerShell engine required by this module
  PowerShellVersion = '3.0'
  
  # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
  DotNetFrameworkVersion = '4.0'
  
  # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
  NestedModules = @(
    '.\src\Close-Resource.ps1',
    '.\src\New-DbCommand.ps1',
    '.\src\Invoke-DbCommand.ps1',
		'.\src\New-SqlConnection.ps1',
		'.\src\Invoke-SqlBulkCopy.ps1'
  )
  
  # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
  FunctionsToExport = @(    
    'Close-Resource',
    'New-DbCommand',
		'Invoke-DbCommand',
    'New-SqlConnection',
		'Invoke-SqlBulkCopy'
  )
}
