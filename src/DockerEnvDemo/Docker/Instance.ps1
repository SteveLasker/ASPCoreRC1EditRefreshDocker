#
# Instance.ps1
#
# Set the environment variables for the docker machine to connect to
Param(
    [String]$Machine
)
    docker-machine.exe env $Machine --shell powershell | Invoke-Expression
    docker run -d stevelasker/devinacontainer
