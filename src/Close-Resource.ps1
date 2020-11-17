<#
  .SYNOPSIS
      Optionally close & dispose a resource.

  .DESCRIPTION
      Provided an input object will optionally, based on method existence, will
      close and/or dispose the object.

  .PARAMETER InputObject
      The resource(s) that needs to be closed and/or disposed.

  .EXAMPLE
      PS C:\> Close-Resource -InputObject $someCloseableDispoable, $a, $b
      
  .EXAMPLE
      PS C:\> $someCloseableDisposable, $a, $b | Close-Resource
#>
function Close-Resource {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $True, 
      ValueFromPipeline = $True)]
    $InputObject)

  begin {}

  process {
    if ($InputObject) {
      foreach ($o in $InputObject) {
        if ($o) {
          if (Get-Member -InputObject $o -MemberType Method -Name Close) {
            Write-Verbose "Close-Resource: Closing resource $o"
            $o.Close()
          }

          if (Get-Member -InputObject $o -MemberType Method -Name Dispose) {
            Write-Verbose "Close-Resource: Disposing resource $o"
            $o.Dispose()
          }
        }
      }
    }
  }

  end {}
}