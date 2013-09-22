<#
#>

#requires -version 2.0
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Path -path $_ -Pathtype Leaf})]
	[string]$FileToImport = 'C:\Users\andy\Documents\Code\cachedb\scratchpad\GCF7C6.gpx',
	[Parameter(Mandatory=$true)]
	[ValidateScript({Test-Connection -computername $_.Split('\')[0] -quiet})]
	[string]$SQLInstance = 'Hobbes\sqlexpress',
	[Parameter(Mandatory=$true)]
	[string]$Database = 'Geocaches'
)
clear-host;
$Error.Clear();
Push-Location;
import-module sqlps;
Pop-Location;

#region Globals
$SQLConnectionString = "Server=$SQLInstance;Database=$Database;Trusted_Connection=True;";
$SQLConnection = new-object System.Data.SqlClient.SqlConnection;
$SQLConnection.ConnectionString = $SQLConnectionString;
$SQLConnection.Open();
#endregion

#region functions
function Get-DBTypeFromTrueFalse{
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[string]$XmlValue
)
	switch ($XmlValue.ToLower()) {
		"true" { 1; }
		"false" { 0; }
		default { 0;}
	}
}

function Update-Cacher {
[cmdletbinding()]
param(
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacherDetails")]
	[string]$CacherName,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacherDetails")]
	[int]$CacherId,
	[Parameter(Mandatory=$true,ParameterSetName="CacherObject")]
	[object]$Cacher
)
	begin {
		$CacherExistsCmd = $SQLConnection.CreateCommand();
		$CacherExistsCmd.CommandText = "select count(1) from cachers where cacherid = @CacherId;"
		$CacherExistsCmd.Parameters.Add("@CacherId", [System.Data.SqlDbType]::int)|out-null;
		$CacherExistsCmd.Prepare();
		$CacherTableUpdateCmd = $SQLConnection.CreateCommand();
		$CacherTableUpdateCmd.Parameters.Add("@CacherId", [System.Data.SqlDbType]::int);
		$CacherTableUpdateCmd.Parameters.Add("@CacherName", [System.Data.SqlDbType]::varchar, 50);
	}
	process{
		switch ($PsCmdlet.ParameterSetName) {
			"CacherObject" {$CacherName = $Cacher.innertext;$CacherId= $Cacher.id;}
		}
		
		$CacherExistsCmd.Parameters["@CacherId"].Value = $CacherId;
		$CacherExists = $CacherExistsCmd.ExecuteScalar();
		if ($CacherExists){
		# Update cacher name if it's changed
			$CacherTableUpdateCmd.CommandText = "update cachers set cachername = @CacherName where cacherid = @CacherId and cachername <> @CacherName;";
		} else {
		    $CacherTableUpdateCmd.CommandText = "insert into cachers (cacherid, cachername) values (@CacherId, @CacherName);";
		}
		$CacherTableUpdateCmd.Parameters["@CacherId"].Value = $CacherId;
		$CacherTableUpdateCmd.Parameters["@CacherName"].Value = $CacherName;
		$CacherTableUpdateCmd.ExecuteNonQuery();
	}
	end {
		$CacherExistsCmd.Dispose();
		$CacherTableUpdateCmd.Dispose();
	}
}

function Update-Caches{
[cmdletbinding()]
param(
)
	begin {
	}
	process {
	}
	end {
	}
}

function Update-CacheOwner {
[cmdletbinding()]
param(
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacheOwnerDetails")]
	[string]$GCNum,
	[Parameter(Mandatory=$true,ParameterSetName="ExplicitCacheOwnerDetails")]
	[int]$OwnerId
)
	begin {
		$CacheHasOwnerCmd = $SQLConnection.CreateCommand();
		$CacheHasOwnerCmd.CommandText = "select count(1) as CacheOnOwners from cache_owners where cacheid = @gcnum;";
		$CacheHasOwnerCmd.Parameters.Add("@gcnum", [System.Data.SqlDbType]::varchar, 8);
		$CacheHasOwnerCmd.Prepare();
	
		$CacheOwnerUpdateCmd = $SQLConnection.CreateCommand();
		$CacheOwnerUpdateCmd.Parameters.Add("@ownerid", [System.Data.SqlDbType]::int)|Out-Null;
		$CacheOwnerUpdateCmd.Parameters.Add("@gcnum", [System.Data.SqlDbType]::varchar, 8)|Out-Null;
	}
	process {
		# Check to see if cache is already on the owner table. If owner has changed, update with new value. If cache isn't on the table, add it
		$CacheHasOwnerCmd.Parameters["@gcnum"].Value = $GCNum;
		$CacheHasOwner = $CacheHasOwnerCmd.ExecuteScalar();
		
		if ($CacheHasOwner) {
			$CacheOwnerUpdateCmd.CommandText = "update cache_owners set cacherid = @ownerid where cacheid = @GCNum and cacherid <> @ownerid;"
		} else {
			$CacheOwnerUpdateCmd.CommandText = "insert into cache_owners (cacherid, cacheid) values (@OwnerId, @GCNum);"
		}
		$CacheOwnerUpdateCmd.Parameters["@ownerid"].Value = $ownerid;
		$CacheOwnerUpdateCmd.Parameters["@gcnum"].Value = $gcnum;
		$CacheOwnerUpdateCmd.ExecuteNonQuery();
	}
	end {
		$CacheOwnerUpdateCmd.Dispose();
		$CacheOwnerUpdateCmd.Dispose();
	}
}

function New-TravelBug {
[cmdletbinding()]
param (
)
{
	begin {
	}
	process {
	}
	end {
	}
}

function Add-TravelBugToCache {
[cmdletbinding()]
param (
)
	begin {
	}
	process {
	}
	end {
	}
}

function Update-TravelBugs {
[cmdletbinding()]
param (
	[Parameter(Mandatory=$true)]
	[object]$AllTBs
)
	begin {
		$TBCheckCmd = $SQLConnection.CreateCommand();
		$TBCheckCmd.CommandText = "select count(1) as tbexists from travelbugs where tbinternalid = @tbid";
		$TBCheckCmd.Parameters.Add("@tbid", [System.Data.SqlDbType]::Int)|Out-Null;
		$TBCheckCmd.Prepare();

		$TBInsertCmd = $SQLConnection.CreateCommand();
		$TBInsertCmd.CommandText = "insert into travelbugs (tbinternalid, tbpublicid,tbname) values (@tbid, @tbpublicid, @tbname)";
		$TBInsertCmd.Parameters.Add("@tbid", [System.Data.SqlDbType]::Int)|Out-Null;
		$TBInsertCmd.Parameters.Add("@tbpublicid", [System.Data.SqlDbType]::varchar, 8)|Out-Null;
		$TBInsertCmd.Parameters.Add("@tbname", [System.Data.SqlDbType]::varchar, 50)|Out-Null;
		$TBInsertCmd.Prepare();

		$TBRemoveFromCacheInventoryCmd = $SQLConnection.CreateCommand();
		$TBRemoveFromCacheInventoryCmd.CommandText = "delete from tbinventory where cacheid <> @cacheid and tbpublicid = @tbpublicid";
		$TBRemoveFromCacheInventoryCmd.Parameters.Add("@tbpublicid", [System.Data.SqlDbType]::VarChar, 50)|Out-Null;
		$TBRemoveFromCacheInventoryCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar, 8)|Out-Null;
		$TBRemoveFromCacheInventoryCmd.Prepare();

		$TBAddToCacheCmd = $SQLConnection.CreateCommand();
		$TBAddToCacheCmd.CommandText = "insert into tbinventory (cacheid, tbpublicid) values (@cacheid,@tbpublicid)";
		$TBAddToCacheCmd.Parameters.Add("@tbpublicid", [System.Data.SqlDbType]::VarChar, 50)|Out-Null;
		$TBAddToCacheCmd.Parameters.Add("@cacheid", [System.Data.SqlDbType]::VarChar, 8)|Out-Null;
		$TBAddToCacheCmd.Prepare();
	}
	process{
		$AllTBs | foreach-object {
			$TBCheckCmd.Parameters["@tbid"].Value = $_.id;
			$TBExists = $TBCheckCmd.ExecuteScalar();
		    if (!$TBExists) {
				$TBInsertCmd.Parameters["@tbid"].Value = $_.id;
				$TBInsertCmd.Parameters["@tbname"].Value = $_.name;
				$TBInsertCmd.Parameters["@tbpublicid"].Value = $_.ref;
				$TBInsertCmd.ExecuteNonQuery();
			}
			
			$TBRemoveFromCacheInventoryCmd.Parameters["@cacheid"].Value = $GCNum;
			$TBRemoveFromCacheInventoryCmd.Parameters["@tbpublicid"].Value = $_.ref;
			$TBWasInOtherCache = $TBRemoveFromCacheInventoryCmd.ExecuteNonQuery();
			if (!$TBExists -or $TBWasInOtherCache) {
				$TBAddToCacheCmd.Parameters["@cacheid"].Value = $gcnum;
				$TBAddToCacheCmd.Parameters["@tbpublicid"].Value = $_.ref;
				$TBAddToCacheCmd.ExecuteNonQuery();
			}
		}
	}
	end {
	}
}
# TODO: Get a more correct verb
function Link-TravelbugToCache {
[cmdletbinding()]
param (
)
}
function Update-TravelBug {
[cmdletbinding()]
param (
)
}
#endregion

# Get Type & Size lookup tables
$PointTypeLookup = invoke-sqlcmd -server $SQLInstance -database $Database -query "select typeid, typename from point_types;";
$CacheSizeLookup = invoke-sqlcmd -server $SQLInstance -database $Database -query "select sizeid, sizename from cache_sizes;";

[xml]$cachedata = get-content $FileToImport;

# For each $cachedata.gpx.wpt
# Check for a cache child element
# If one exists, it's a cache
# Otherwise, it's a waypoint

$GCNum = $cachedata.gpx.wpt.name;
$CacheLoadCmd = $SQLConnection.CreateCommand();
$CacheExistsCmd = $SQLConnection.CreateCommand();
$CacheExistsCmd.CommandText = "select count(1) from caches where cacheid = @CacheId;";
$CacheExistsCmd.Parameters.Add("@CacheId", [System.Data.SqlDbType]::varchar,8)|out-null;
$CacheExistsCmd.Prepare();
$CacheExistsCmd.Parameters["@CacheId"].Value = $GCNum;
$CacheExists = $CacheExistsCmd.ExecuteScalar();


# Load/Update cache table
# TODO: Use GPX time for Last Updated. $cachedata.gpx.time
if (!$CacheExists){
    $CacheLoadCmd.CommandText = @"
INSERT INTO [dbo].[caches]
           ([cacheid]
           ,[gsid]
           ,[cachename]
           ,[latitude]
           ,[longitude]
           ,[lastupdated]
           ,[placed]
           ,[placedby]
           ,[typeid]
           ,[sizeid]
           ,[difficulty]
           ,[terrain]
           ,[shortdesc]
           ,[longdesc]
           ,[hint]
           ,[available]
           ,[archived]
           ,[premiumonly])
     VALUES
           (@CacheId
           ,@GSID
           ,@CacheName
           ,@Lat
           ,@Long
           ,getdate()
           ,@Placed
           ,@PlacedBy
           ,@TypeId
           ,@SizeId
           ,@Diff
           ,@Terrain
           ,@ShortDesc
           ,@LongDesc
           ,@Hint
           ,@Avail
           ,@Archived
           ,@PremOnly
           );
"@;
} else {
    $CacheLoadCmd.CommandText = @"
UPDATE [dbo].[caches]
   SET [gsid] = @gsid
      ,[cachename] = @CacheName
      ,[latitude] = @Lat
      ,[longitude] = @Long
      ,[lastupdated] = getdate()
      ,[placed] = @Placed
      ,[placedby] = @PlacedBy
      ,[typeid] = @TypeId
      ,[sizeid] = @SizeId
      ,[difficulty] = @Diff
      ,[terrain] = @Terrain
      ,[shortdesc] = @ShortDesc
      ,[longdesc] = @LongDesc
      ,[hint] = @Hint
      ,[available] = @Avail
      ,[archived] = @Archived
      ,[premiumonly] = @PremOnly
 WHERE CacheId = @CacheId;
"@;
}
# Set parameters
$CacheLoadCmd.Parameters.Add("@CacheId", [System.Data.SqlDbType]::varchar, 8)|out-null;
$CacheLoadCmd.Parameters.Add("@gsid", [System.Data.SqlDbType]::int)|out-null;
$CacheLoadCmd.Parameters.Add("@CacheName", [System.Data.SqlDbType]::nvarchar, 50)|out-null;
$CacheLoadCmd.Parameters.Add("@Lat", [System.Data.SqlDbType]::float)|out-null;
$CacheLoadCmd.Parameters.Add("@Long", [System.Data.SqlDbType]::float)|out-null;
$CacheLoadCmd.Parameters.Add("@Placed", [System.Data.SqlDbType]::datetime)|out-null;
$CacheLoadCmd.Parameters.Add("@PlacedBy", [System.Data.SqlDbType]::nvarchar)|out-null;
$CacheLoadCmd.Parameters.Add("@TypeId", [System.Data.SqlDbType]::int)|out-null;
$CacheLoadCmd.Parameters.Add("@SizeId", [System.Data.SqlDbType]::int)|out-null;
$CacheLoadCmd.Parameters.Add("@Diff", [System.Data.SqlDbType]::float)|out-null;
$CacheLoadCmd.Parameters.Add("@Terrain", [System.Data.SqlDbType]::float)|out-null;
$CacheLoadCmd.Parameters.Add("@ShortDesc", [System.Data.SqlDbType]::nvarchar, 5000)|out-null;
#See http://support.microsoft.com/kb/970519 for bug workaround
$CacheLoadCmd.Parameters["@ShortDesc"].Size = -1;
$CacheLoadCmd.Parameters.Add("@LongDesc", [System.Data.SqlDbType]::ntext)|out-null;
$CacheLoadCmd.Parameters.Add("@Hint", [System.Data.SqlDbType]::nvarchar, 1000)|out-null;
$CacheLoadCmd.Parameters.Add("@Avail", [System.Data.SqlDbType]::bit)|out-null;
$CacheLoadCmd.Parameters.Add("@Archived", [System.Data.SqlDbType]::bit)|out-null;
$CacheLoadCmd.Parameters.Add("@PremOnly", [System.Data.SqlDbType]::bit)|out-null;
#$CacheLoadCmd.Prepare();

$CacheLoadCmd.Parameters["@CacheId"].Value = $GCNum;
$CacheLoadCmd.Parameters["@gsid"].Value = $cachedata.gpx.wpt.cache.id;
$CacheLoadCmd.Parameters["@CacheName"].Value = $cachedata.gpx.wpt.cache.name;
$CacheLoadCmd.Parameters["@Lat"].Value = $cachedata.gpx.wpt.lat;
$CacheLoadCmd.Parameters["@Long"].Value = $cachedata.gpx.wpt.lon;
$CacheLoadCmd.Parameters["@Placed"].Value = get-date $cachedata.gpx.wpt.time;
$CacheLoadCmd.Parameters["@PlacedBy"].Value = $cachedata.gpx.wpt.cache.placed_by;
$CacheLoadCmd.Parameters["@TypeId"].Value = $PointTypeLookup|?{$_.typename -eq $cachedata.gpx.wpt.cache.type}|select -expandproperty typeid;
$CacheLoadCmd.Parameters["@SizeId"].Value = $CacheSizeLookup|?{$_.sizename -eq $cachedata.gpx.wpt.cache.container}|select -expandproperty sizeid;
$CacheLoadCmd.Parameters["@Diff"].Value = $cachedata.gpx.wpt.cache.difficulty;
$CacheLoadCmd.Parameters["@Terrain"].Value = $cachedata.gpx.wpt.cache.terrain;
$CacheLoadCmd.Parameters["@ShortDesc"].Value = $cachedata.gpx.wpt.cache.short_description.innertext;
$CacheLoadCmd.Parameters["@LongDesc"].Value = $cachedata.gpx.wpt.cache.long_description.innertext;
$CacheLoadCmd.Parameters["@Hint"].Value = $cachedata.gpx.wpt.cache.encoded_hints;
$CacheLoadCmd.Parameters["@Avail"].Value = Get-DBTypeFromTrueFalse $cachedata.gpx.wpt.cache.available;
$CacheLoadCmd.Parameters["@Archived"].Value = Get-DBTypeFromTrueFalse $cachedata.gpx.wpt.cache.archived;
# TODO: Figure out where premium only comes from. Doesn't appear to be in the GPX
$CacheLoadCmd.Parameters["@PremOnly"].Value = 0; #Get-DBTypeFromTrueFalse $cachedata.gpx.wpt.
# Execute
$CacheLoadCmd.ExecuteNonQuery();

# Load cacher table if no record for current cache's owner, or update name
Update-Cacher -Cacher $cachedata.gpx.wpt.cache.owner;
Update-CacheOwner -GCNum $GCNum -OwnerId $OwnerId

# Insert attributes & TBs into respective tables
$attributes = $cachedata.gpx.wpt.cache.attributes|foreach-object{$_.attribute|select id,"#text"};

$CacheAttributeCheckCmd = $SQLConnection.CreateCommand();
$CacheAttributeCheckCmd.CommandText = "select count(1) as attrexists from attributes where attributeid = @attrid";
$CacheAttributeCheckCmd.Parameters.Add("@attrid", [System.Data.SqlDbType]::Int)|Out-Null;
$CacheAttributeCheckCmd.Prepare();

$CacheAttributeInsertCmd = $SQLConnection.CreateCommand();
$CacheAttributeInsertCmd.CommandText = "insert into attributes (attributeid,attributename) values (@attrid, @attrname)";
$CacheAttributeInsertCmd.Parameters.Add("@attrid", [System.Data.SqlDbType]::Int)|Out-Null;
$CacheAttributeInsertCmd.Parameters.Add("@attrname", [System.Data.SqlDbType]::varchar, 50)|Out-Null;
$CacheAttributeInsertCmd.Prepare();
$attributes | foreach-object {
	$CacheAttributeCheckCmd.Parameters["@attrid"].Value = $_.id;
	$AttrExists = $CacheAttributeCheckCmd.ExecuteScalar();
    if (!$AttrExists) {
		$CacheAttributeInsertCmd.Parameters["@attrid"].Value = $_.id;
		$AttrName = $_|Select-Object -ExpandProperty "#text";
		$CacheAttributeInsertCmd.Parameters["@attrname"].Value = $AttrName;
		$CacheAttributeInsertCmd.ExecuteNonQuery();
    }
}
# TODO: Link attributes to cache

$tbs = $cachedata.gpx.wpt.cache.travelbugs|foreach-object{$_.travelbug};
#TODO: Make this pipeline aware with $cachedata.gpx.wpt.cache.travelbugs.travelbug|update-travelbugs
Update-TravelBugs $tbs;
$logs = $cachedata.gpx.wpt.cache.logs.log;
# TODO: Make this pipeline aware with $logs.finder |Update-Cacher
$logs|ForEach-Object{Update-Cacher -Cacher $_.finder};
$SQLConnection.Close();
remove-module sqlps;
