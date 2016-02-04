Param(
    [Parameter(ParameterSetName = "Build", Mandatory = $True)]
    [switch]$Build,
    [Parameter(ParameterSetName = "Clean", Mandatory = $True)]
    [switch]$Clean,
    [Parameter(ParameterSetName = "Run", Mandatory = $True)]
    [switch]$Run,
    [parameter(ParameterSetName = "Clean", Position = 1, Mandatory = $True)]
    [parameter(ParameterSetName = "Build", Position = 1, Mandatory = $True)]
    [parameter(ParameterSetName = "Run", Position = 1, Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [String]$Environment,
    [parameter(ParameterSetName = "Clean", Position = 2, Mandatory = $True)]
    [parameter(ParameterSetName = "Build", Position = 2, Mandatory = $True)]
    [parameter(ParameterSetName = "Run", Position = 2, Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [String]$Machine,
    [parameter(ParameterSetName = "Clean", Position = 3, Mandatory = $False)]
    [parameter(ParameterSetName = "Build", Position = 3, Mandatory = $False)]
    [parameter(ParameterSetName = "Run", Position = 3, Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [String]$ProjectFolder = "$(Get-Location)",
    [parameter(ParameterSetName = "Build", Position = 4, Mandatory = $False)]
    [switch]$NoCache,
    [parameter(ParameterSetName = "Run", Position = 4, Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [String]$Port = 5000
)

$ErrorActionPreference = "Stop"
$ImageName = "dockerenvdemo_dockerenvdemo"

# Kills all containers using an image, removes all containers using an image, and removes the image.
function Clean() {
    $composeFileName= Join-Path $ProjectFolder "docker-compose.$Environment.yml"

    if (Test-Path $composeFileName) {
        Write-Host "Cleaning image $ImageName"

        cmd /c docker-compose -f $composeFileName kill "2>&1"
        if($? -eq $False) {
            Write-Error "Failed to kill the running containers"
        }

        cmd /c docker-compose -f $composeFileName rm -f "2>&1"
        if($? -eq $False) {
            Write-Error "Failed to remove the stopped containers"
        }

        $ImageNameRegEx = "\b$ImageName\b"

        # If $ImageName exists remove it
        docker images | select-string -pattern $ImageNameRegEx | foreach {
            $imageName = $_.Line.split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)[0];
            $tag = $_.Line.split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)[1];
            $imageNameWithTag = $imageName + ":" + $tag
            Write-Host "Removing image $imageNameWithTag";
            docker rmi $imageNameWithTag *>&1 | Out-Null
        }
    }
    else {
        Write-Error -Message "$Environment is not a valid parameter. File '$composeFileName' does not exist." -Category InvalidArgument
    }
}

# Runs docker build.
function Build () {
    $composeFileName= Join-Path $ProjectFolder "docker-compose.$Environment.yml"

    if (Test-Path $composeFileName) {
        $buildArgs = ""
        if($NoCache)
        {
            $buildArgs = "--no-cache"
        }

        cmd /c docker-compose -f $composeFileName build $buildArgs "2>&1"
        if($? -eq $False) {
            Write-Error "Failed to build the image"
        }

        $tag = [System.DateTime]::Now.ToString("yyyy-MM-dd_HH-mm-ss")
        $imageNameWithTag = $ImageName + ":" + $tag

        cmd /c docker tag $ImageName $imageNameWithTag "2>&1"
        if($? -eq $False) {
            Write-Error "Failed to tag the image"
        }
    }
    else {
        Write-Error -Message "$Environment is not a valid parameter. File '$composeFileName' does not exist." -Category InvalidArgument
    }
}

# Runs docker run
function Run () {
    $composeFileName= Join-Path $ProjectFolder "docker-compose.$Environment.yml"

    if (Test-Path $composeFileName) {
        cmd /c docker-compose -f $composeFileName up -d "2>&1"
        if($? -eq $False) {
            Write-Error "Failed to build the images"
        }
    }
    else {
        Write-Error -Message "$Environment is not a valid parameter. File '$composeFileName' does not exist." -Category InvalidArgument
    }

    OpenSite
}

# Opens the remote site
function OpenSite () {
    $uri = "http://$(docker-machine ip $(docker-machine active)):$Port"
    Write-Host "Opening site $uri " -NoNewline
    $status = 0

    #Check if the site is available
    while($status -ne 200) {
        try {
            $response = Invoke-WebRequest -Uri $uri -Headers @{"Cache-Control"="no-cache";"Pragma"="no-cache"} -UseBasicParsing
            $status = [int]$response.StatusCode
        }
        catch [System.Net.WebException] { }
        if($status -ne 200) {
            Write-Host "." -NoNewline
            Start-Sleep 1
        }
    }

    Write-Host
    # Open the site.
    Start-Process $uri
}

# Set the environment variables for the docker machine to connect to
docker-machine.exe env $Machine --shell powershell | Invoke-Expression

# Need the full path of the project for mapping
$ProjectFolder = Resolve-Path $ProjectFolder

# Convert the local windows path to its mapped linux equivalent
$winRoot = [System.IO.Path]::GetPathRoot($ProjectFolder)
$winSubPath = $ProjectFolder.Substring($winRoot.Length)
$linuxRoot = "/" + $winRoot.TrimEnd(":\").ToLowerInvariant()
$linuxPath = $linuxRoot + "/" + $winSubPath.Replace("\", "/")

# Set the environment variables that are used by the compose file
$env:DOCKERENVDEMO_PATH = $linuxPath
$env:DOCKERENVDEMO_PORT = $Port

# Call the correct functions for the parameters that were used
if ($Clean) {
    Clean
}
if($Build) {
    Build
}
if($Run) {
    Run
}