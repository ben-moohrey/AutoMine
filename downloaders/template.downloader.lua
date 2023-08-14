-- URL to the manifest file on GitHub
local manifestURL = "http://raw.githubusercontent.com/%%GITHUB_USERNAME%%/%%GITHUB_REPO%%/%%GITHUB_BRANCH%%/manifest.json"

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

-- Recursively list all files and folders under a directory
local function listAll(dir)
    local list = {}
    local function _list(d)
        for _, f in ipairs(fs.list(d)) do
            local path = fs.combine(d, f)
            table.insert(list, path)
            if fs.isDir(path) then
                _list(path)
            end
        end
    end
    _list(dir)
    return list
end

local function clearOldFiles(manifest)
    local filesToDelete = {}
    local repoDir = fs.combine("/", "%%GITHUB_REPO%%")
    
    local allFiles = listAll(repoDir)
    for _, file in ipairs(allFiles) do
        if not manifest[file] then
            table.insert(filesToDelete, file)
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
        print("Downloading " .. path .. " from " .. info.url)
        downloadFile(info.url, path)
    end

    print("All files downloaded successfully!")
end

main()
