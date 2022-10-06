# C# implementation #

## Debug in Code OSS ##

````
"pipeTransport": {
                "pipeCwd": "${workspaceFolder}",
                "pipeProgram": "bash",
                "pipeArgs": ["-c"],
                "debuggerPath": "netcoredbg"
            }
````

## Build ##

```
dotnet restore --use-current-runtime && dotnet clean && dotnet publish -c Release --use-current-runtime --self-contained false --no-restore -o app
```
