-- URL to the manifest file on GitHub
local manifestURL = "http://raw.githubusercontent.com/ben-moohrey/AutoMine/main/manifest.json"


function getFirstPartOfPath(path)
    return string.match(path, "^(/+[^/]+)")
end
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
    
    if (not fs.exists(manifest.project_path)) then
        return
    end

    local allFiles = fs.list(manifest.project_path)

    for _, file in ipairs(allFiles) do
        if not manifest.files[file] then
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
    for path, info in pairs(manifest.files) do
        print("Downloading " .. path .. " from " .. info.url)
        downloadFile(info.url, path)
    end

    print("All files downloaded successfully!")
end

main()
