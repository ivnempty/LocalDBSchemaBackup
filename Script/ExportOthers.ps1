function GenerateDBScript([string]$scriptpath)
{
  [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
  [System.Reflection.Assembly]::LoadWithPartialName("System.Data") | Out-Null
  
  $srv = new-object "Microsoft.SqlServer.Management.SMO.Server" "(local)"
  
  $options = New-Object "Microsoft.SqlServer.Management.SMO.ScriptingOptions"
  $options.AllowSystemObjects = $false
  $options.IncludeDatabaseContext = $true
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

  $scr = New-Object "Microsoft.SqlServer.Management.Smo.Scripter"
  $scr.Options = $options
  $scr.Server = $srv
  
  #=================
  # Linked Servers
  #=================
  $linkedServers = $srv.LinkedServers
  if ($linkedServers -ne $null)
  {
	foreach ($ls in $linkedServers)
	{
	  $options.FileName = $scriptpath + "\LinkedServers\$($ls.Name).sql"
      New-Item $options.FileName -type file -force | Out-Null
	  $scr.Script($ls)
	}
  }

  #=============
  # Agent Jobs
  #=============
  $jobs = $srv.JobServer.Jobs
  if ($jobs -ne $null)
  {
	foreach ($job in $jobs)
	{
	  $options.FileName = $scriptpath + "\Jobs\$($job.Name).sql"
      New-Item $options.FileName -type file -force | Out-Null
	  $scr.Script($job)
	}
  }
}

#=============
# Execute
#=============
GenerateDBScript $args[0]