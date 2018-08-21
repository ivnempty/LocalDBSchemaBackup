function GenerateDBScript([string]$dbname, [string]$scriptpath)
{
  [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
  [System.Reflection.Assembly]::LoadWithPartialName("System.Data") | Out-Null
  $srv = new-object "Microsoft.SqlServer.Management.SMO.Server" "(local)"
  $srv.SetDefaultInitFields([Microsoft.SqlServer.Management.SMO.View], "IsSystemObject")
  $db = New-Object "Microsoft.SqlServer.Management.SMO.Database"
  $db = $srv.Databases[$dbname]
  $scr = New-Object "Microsoft.SqlServer.Management.Smo.Scripter"
  $deptype = New-Object "Microsoft.SqlServer.Management.Smo.DependencyType"
  $scr.Server = $srv
  $options = New-Object "Microsoft.SqlServer.Management.SMO.ScriptingOptions"
  $options.AllowSystemObjects = $false
  $options.IncludeDatabaseContext = $false
  $options.IncludeIfNotExists = $false
  $options.ClusteredIndexes = $true
  $options.Default = $true
  $options.DriAll = $true
  $options.Indexes = $true
  $options.NonClusteredIndexes = $true
  $options.IncludeHeaders = $false
  $options.ToFileOnly = $true
  $options.AppendToFile = $true
  $options.ScriptDrops = $false
  $options.NoCollation = $true
  $options.AnsiPadding = $true
  $enc = [System.Text.Encoding]::UTF8
  $options.Encoding = $enc

  # Set options for SMO.Scripter
  $scr.Options = $options
  
  $folder = $scriptpath + "\Databases\$dbname"

  #=============
  # Tables
  #=============
  $tables = $db.Tables | where {$_.IsSystemObject -eq $FALSE}
  if ($tables -ne $null)
  {
    foreach ($tb in $tables)
	{
	  $options.FileName = $folder + "\Tables\$($tb.Schema).$($tb.Name).sql"
      New-Item $options.FileName -type file -force | Out-Null
	  $scr.Script($tb)
	  
	  #=============
      # Table Triggers
      #=============
	  foreach ($trigger in $tb.triggers)
      {
  		$options.FileName = $folder + "\Triggers\$($trigger.Name).sql"
  		New-Item $options.FileName -type file -force | Out-Null
        $scr.Script($trigger)
      }
	}
  }

  #=============
  # Views
  #=============
  $views = $db.Views | where {$_.IsSystemObject -eq $false}
  if ($views -ne $null)
  {
    foreach ($view in $views)
    {
  	  $options.FileName = $folder + "\Views\$($view.Schema).$($view.Name).sql"
  	  New-Item $options.FileName -type file -force | Out-Null
     $scr.Script($view)
   }
  }

  #===================
  # StoredProcedures
  #===================
  $StoredProcedures = $db.StoredProcedures | where {$_.IsSystemObject -eq $false}
  if ($StoredProcedures -ne $null)
  {
    foreach ($StoredProcedure in $StoredProcedures)
    {   
  	   $options.FileName = $folder + "\StoredProcedures\$($StoredProcedure.Schema).$($StoredProcedure.Name).sql"
  	   New-Item $options.FileName -type file -force | Out-Null
      $scr.Script($StoredProcedure)
   }
  } 

  #=============
  # Functions
  #=============
  $UserDefinedFunctions = $db.UserDefinedFunctions | where {$_.IsSystemObject -eq $false}
  if ($UserDefinedFunctions -ne $null)
  {
    foreach ($function in $UserDefinedFunctions)
    {
  	  $options.FileName = $folder + "\UserDefinedFunctions\$($function.Schema).$($function.Name).sql"
  	  New-Item $options.FileName -type file -force | Out-Null
     $scr.Script($function)
   }
  } 
}

#=============
# Execute
#=============
GenerateDBScript $args[0] $args[1]