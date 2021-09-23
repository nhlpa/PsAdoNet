<#
  .SYNOPSIS
    Convert a PSObject[] to DataTable.

  .DESCRIPTION
    Creates a new System.Data.DataTable from the provided PSObject[].

  .PARAMETER InputObject
    The PSObject to use.

  .PARAMETER Columns
    The properties to include as output columns (optional). 

  .OUTPUTS 
    System.Data.DataTable

  .EXAMPLE    
    PS C:\> $[PSCustomObject]@{Id = 1; Description = "Description" } | ConvertTo-DataTable
  
  .EXAMPLE    
    PS C:\> Get-Process | Select-Object -First 5 -Property Id, Description | ConvertTo-DataTable
#>
function ConvertTo-DataTable {
  [CmdLetBinding(DefaultParameterSetName = "None")]
  param(
    [Parameter(ValueFromPipeline = $True, 
      ValueFromPipelineByPropertyName = $True)]    
    [PSCustomObject[]]
    $InputObject,
    
    [Parameter(Mandatory = $false)]
    [string[]]
    $Columns)

  begin {
    Write-Verbose "Creating DataTable..."
    [System.Data.DataTable] $dt = New-Object System.Data.DataTable    
  }
  process {       
    if ($InputObject) {
      foreach ($o in $InputObject) {      
        Write-Verbose "Adding row to DataTable ($o)"      
        [System.Data.DataRow]$row = $dt.NewRow()

        $o.PsObject.properties
        | Where-Object MemberType -eq "NoteProperty" 
        | ForEach-Object { 
          $propName = $_.Name

          if (!$Columns -or ($Columns -and $Columns.Contains($propName))) {
            if (-not $dt.Columns.Contains($propName)) {
              Write-Verbose "Adding column ($propName) to DataTable"
              $dt.Columns.Add($propName) | Out-Null              
            }
            
            $propValue = $o.$propName
            Write-Verbose "Assigning $propValue to $propName"
            $row[$propName] = $propValue
          }
        }

        Write-Verbose "Adding row to table"
        $dt.Rows.Add($row) | Out-Null
      }
    }
  }
  end {
    return , $dt
  }
}