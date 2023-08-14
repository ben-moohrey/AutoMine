-- URL to the manifest file on GitHub
local manifestURL = "http://raw.githubusercontent.com/%%GITHUB_USERNAME%%/%%GITHUB_REPO%%/%%GITHUB_BRANCH%%/manifest.json"
local baseDir = "/%%GITHUB_REPO%%"
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

    clearOldFiles(manifest)

    -- Loop through the manifest and download each file
    for path, info in pairs(manifest) do
        local fullPath = fs.combine(baseDir, path)
        print("Downloading " .. fullPath .. " from " .. info.url)
        downloadFile(info.url, fullPath)
    end

    print("All files downloaded successfully!")
end

main()
