@echo off
SETLOCAL
SET SqlDeploy=.\bin\Debug\DDI.SqlDeploy.exe
IF NOT "%1"=="" (
    SET "SqlDeploy=%1"
)
SET cwd=%cd%
cd Tools\DDI.SqlDeploy
%SqlDeploy% recreate -c "server=localhost;database=DDI;Trusted_connection=false;user id=sa;password=Password01;"
%SqlDeploy% deploy -c "server=localhost;database=DDI;Trusted_connection=false;user id=sa;password=Password01;" -i  "..\..\SqlScripts\DDL" -a  "..\..\SqlScripts\PostDeploy" -d  -P  "..\..\SqlScripts\PreDeploy" -O  "..\..\SqlScripts\ProgrammableObjects"  -J  "..\..\SqlScripts\SQLJobs"
cd %cwd%
ENDLOCAL


Severity	Code	Description	Project	File	Line	Suppression State
Error	CS0006	Metadata file '..\..\packages\StyleCop.Analyzers.1.0.0\analyzers\dotnet\cs\Newtonsoft.Json.dll' could not be found	DDI.SqlDeploy	c:\Projects\ddi\Tools\DDI.SqlDeploy\CSC	1	Active
