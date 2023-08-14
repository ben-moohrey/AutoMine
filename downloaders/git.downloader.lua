-- URL to the manifest file on GitHub
local manifestURL = "http://raw.githubusercontent.com/ben-moohrey/AutoMine/main/manifest.json"
local baseDir -- This will be set dynamically after fetching the manifest

-- Fetch the manifest from GitHub
local function fetchManifest(url)
    local handle = http.get(url)
    if not handle then
        error("Failed to fetch manifest")
    end
    local content = handle.readAll()
    handle.close()
    return textutils.unserializeJSON(content)
end

-- Determine base directory from the manifest
local function determineBaseDir(manifest)
    for path, _ in pairs(manifest) do
        return path:match("([^/]+)/") -- Match the first directory in the path
    end
end

-- Download a file from a given URL
local function downloadFile(url, path)
    local handle = http.get(url)
    if not handle then
        error("Failed to fetch " .. url)
    end
    local content = handle.readAll()
    handle.close()

    -- Ensure directory exists
    local directory = fs.getDir(path)
    if not fs.exists(directory) then
        fs.makeDir(directory)
    end

    local file = fs.open(path, "w")
    file.write(content)
    file.close()
end

local function clearOldFiles(manifest)
    local filesToDelete = {}
    
    -- List all files in the base directory
    local allFiles = fs.list(baseDir)
    for _, file in ipairs(allFiles) do
        local fullPath = fs.combine(baseDir, file)
        -- If file in directory is not in the manifest, mark it for deletion
        if not manifest[fullPath] then
            table.insert(filesToDelete, fullPath)
        end
    end

    -- Delete the marked files
    for _, file in ipairs(filesToDelete) do
        fs.delete(file)
    end
end

local function main()
    local manifest = fetchManifest(manifestURL)
    if not manifest then
        error("Failed to parse manifest")
    end

    baseDir = "/" .. determineBaseDir(manifest)

    if not fs.exists(baseDir) then
        fs.makeDir(baseDir)
    end

    clearOldFiles(manifest)

    -- Loop through the manifest and download each file
    for path, info in pairs(manifest) do
        print("Downloading " .. path .. " from " .. info.url)
        downloadFile(info.url, path) -- Using the full path from the manifest without recombining
    end

    print("All files downloaded successfully!")
end

main()
